#!/usr/bin/env python3
"""
CPU AIO strip (6 LEDs):
    Each LED = max utilisation across a group of CPU threads
    (32 threads / 6 groups, sized [6,6,6,5,5,4]). A single pinned thread
    pins one LED. Colour ramps green (idle) -> yellow (50%) -> red (100%).

Front-panel strip (24 LEDs):
    Vertical bar of NVIDIA GPU compute utilisation.
        LED 0  (top)    = 100%
        LED 23 (bottom) = 0%
    Foreground (bar):   purple, fixed.
    Background (track): GPU temperature gradient (blue cold -> red hot).
"""

import argparse
import os
import signal as signal_module
import sys
import time

import psutil
import pynvml
from openrgb import OpenRGBClient
from openrgb.utils import RGBColor

# ---- Configuration ---------------------------------------------------------

CPU_ZONE_PATTERN   = os.environ.get("CPU_ZONE",   "JARGB 3")
FRONT_ZONE_PATTERN = os.environ.get("FRONT_ZONE", "JARGB 2")

CPU_LEDS    = 6
FRONT_LEDS  = 24
FRONT_TEMP_RESERVE = 2   # bottom LEDs always show temperature; bar can't cover them

CPU_ATTACK_S  = 0.5
CPU_HOLD_S    = 1.0
CPU_RELEASE_S = 0.5

BAR_ATTACK_S  = 2.0
BAR_HOLD_S    = 1.0
BAR_RELEASE_S = 2.0

TEMP_ATTACK_S  = 2.0
TEMP_HOLD_S    = 1.0
TEMP_RELEASE_S = 2.0

UPDATE_HZ   = 30
NVML_INDEX  = 0
DEBUG_HZ    = float(os.environ.get("DEBUG_HZ", "2"))  # only used when --verbose
SERVER_HOST = os.environ.get("OPENRGB_HOST", "127.0.0.1")
SERVER_PORT = int(os.environ.get("OPENRGB_PORT", "6742"))

PURPLE = RGBColor(160, 0, 220)

CPU_GRADIENT = [
    (0.0, RGBColor(  0, 255,   0)),
    (0.5, RGBColor(255, 255,   0)),
    (1.0, RGBColor(255,   0,   0)),
]

TEMP_GRADIENT = [
    (0.00, RGBColor(  0,   0, 255)),
    (0.40, RGBColor(  0, 255,   0)),
    (0.50, RGBColor(255, 255,   0)),
    (0.65, RGBColor(255, 128,   0)),
    (0.80, RGBColor(255,   0,   0)),
    (1.00, RGBColor(255,   0, 255)),
]

# ---- Smoothing -------------------------------------------------------------

class PeakHold:
    """Fast-attack, peak-hold, slow-release envelope on a 0..1 signal.

    Rising input ramps up at attack rate and (re)sets the hold timer.
    During hold the value is locked. After hold expires the value
    decays toward the current input at release rate.
    """

    def __init__(self, attack, hold, release):
        self.attack_rate  = 1.0 / attack
        self.release_rate = 1.0 / release
        self.hold_time    = hold
        self.value        = 0.0
        self.hold_until   = 0.0

    def update(self, target, now, dt):
        target = max(0.0, min(1.0, float(target)))
        if target > self.value:
            self.value = min(target, self.value + self.attack_rate * dt)
            self.hold_until = now + self.hold_time
        elif now >= self.hold_until and target < self.value:
            self.value = max(target, self.value - self.release_rate * dt)
        return self.value


# ---- Colour helpers --------------------------------------------------------

def blend(a, b, t):
    t = max(0.0, min(1.0, t))
    return RGBColor(
        int(round(a.red   + (b.red   - a.red)   * t)),
        int(round(a.green + (b.green - a.green) * t)),
        int(round(a.blue  + (b.blue  - a.blue)  * t)),
    )


def gradient(stops, t):
    t = max(0.0, min(1.0, t))
    if t <= stops[0][0]:
        return stops[0][1]
    if t >= stops[-1][0]:
        return stops[-1][1]
    for (p0, c0), (p1, c1) in zip(stops, stops[1:]):
        if p0 <= t <= p1:
            return blend(c0, c1, (t - p0) / (p1 - p0))
    return stops[-1][1]


# ---- Layers ----------------------------------------------------------------
# Each layer is a list of (RGBColor, alpha) tuples, one per LED.

def fill(color, n, alpha=1.0):
    return [(color, alpha)] * n


def per_led(values, stops):
    return [(gradient(stops, v), 1.0) for v in values]


def bar(fraction, color, n, top_at=0, reserve=0):
    """Vertical progress bar with sub-LED anti-aliased leading edge.

    fraction: 0..1 fill of the bar's active span (0 = empty, 1 = span full).
    top_at:   index of the 100% end — the LED that lights LAST.
              top_at=0 means the bar grows from the bottom toward LED 0.
    reserve:  LEDs at the 0% (bottom) end left permanently transparent, so a
              background layer (e.g. temperature) is always visible there.

    With top_at=0 the bar occupies LEDs [0 .. n-1-reserve] and fills from
    LED (n-1-reserve) up toward LED 0; LEDs [n-reserve .. n-1] stay clear.
    """
    span = max(1, n - reserve)
    fill_leds = max(0.0, min(float(span), fraction * span))
    out = []
    for i in range(n):
        # distance from the 0% end of the active span, in LED units
        d = (n - 1 - reserve - i) if top_at == 0 else (i - reserve)
        alpha = 0.0 if d < 0 else max(0.0, min(1.0, fill_leds - d))
        out.append((color, alpha))
    return out


def composite(layers, n):
    """Alpha-blend layers bottom-up. Returns list of RGBColor."""
    r = [0] * n
    g = [0] * n
    b = [0] * n
    for layer in layers:
        for i, (c, a) in enumerate(layer):
            if a <= 0.0:
                continue
            if a >= 1.0:
                r[i], g[i], b[i] = c.red, c.green, c.blue
            else:
                r[i] = int(round(r[i] + (c.red   - r[i]) * a))
                g[i] = int(round(g[i] + (c.green - g[i]) * a))
                b[i] = int(round(b[i] + (c.blue  - b[i]) * a))
    return [RGBColor(r[i], g[i], b[i]) for i in range(n)]


# ---- Device wiring ---------------------------------------------------------

def find_zone(client, pattern, expected_leds):
    needle = pattern.lower()
    matches = [
        (d, z)
        for d in client.devices
        for z in d.zones
        if needle in z.name.lower()
    ]
    if not matches:
        available = "\n".join(
            f"  {d.name!r} zone {zi}: {z.name!r} ({len(z.leds)} LEDs)"
            for d in client.devices
            for zi, z in enumerate(d.zones)
        )
        raise RuntimeError(
            f"No zone matching {pattern!r}. Available zones:\n{available}"
        )
    sized = [m for m in matches if len(m[1].leds) == expected_leds]
    dev, zone = (sized or matches)[0]
    print(f"  matched {dev.name!r} -> {zone.name!r} ({len(zone.leds)} LEDs)")
    return dev, zone


def set_direct_mode(dev):
    for mode in dev.modes:
        if mode.name.lower() == "direct":
            dev.set_mode(mode.name)
            return
    print(f"  WARNING: {dev.name!r} has no 'Direct' mode; per-LED writes may be ignored")


# ---- Sensors ---------------------------------------------------------------

def chunk_indices(total, n):
    k, m = divmod(total, n)
    out, start = [], 0
    for i in range(n):
        size = k + (1 if i < m else 0)
        out.append(list(range(start, start + size)))
        start += size
    return out


class CpuSensor:
    def __init__(self, n_groups):
        psutil.cpu_percent(percpu=True)  # warmup; first call returns zeros
        self.groups = chunk_indices(psutil.cpu_count(logical=True), n_groups)
        print(f"  CPU: {sum(len(g) for g in self.groups)} threads / "
              f"{n_groups} groups, sizes {[len(g) for g in self.groups]}")

    def read(self):
        per_thread = psutil.cpu_percent(percpu=True)
        return [max(per_thread[i] for i in idxs) / 100.0 for idxs in self.groups]


class GpuSensor:
    def __init__(self, index=0):
        pynvml.nvmlInit()
        self.handle = pynvml.nvmlDeviceGetHandleByIndex(index)
        name = pynvml.nvmlDeviceGetName(self.handle)
        if isinstance(name, bytes):
            name = name.decode()
        print(f"  GPU[{index}]: {name}")

    def read(self):
        util = pynvml.nvmlDeviceGetUtilizationRates(self.handle).gpu / 100.0
        temp = pynvml.nvmlDeviceGetTemperature(self.handle, pynvml.NVML_TEMPERATURE_GPU)
        return util, temp / 100.0

    def close(self):
        try:
            pynvml.nvmlShutdown()
        except Exception:
            pass


# ---- Main loop -------------------------------------------------------------

def main(verbose=False):
    print(f"Connecting to OpenRGB SDK at {SERVER_HOST}:{SERVER_PORT} ...")
    client = OpenRGBClient(SERVER_HOST, SERVER_PORT, "lighting-controller")
    print(f"Connected. {len(client.devices)} device(s) detected.")

    print(f"\nResolving CPU zone (pattern={CPU_ZONE_PATTERN!r}):")
    cpu_dev, cpu_zone = find_zone(client, CPU_ZONE_PATTERN, CPU_LEDS)
    print(f"Resolving front-panel zone (pattern={FRONT_ZONE_PATTERN!r}):")
    front_dev, front_zone = find_zone(client, FRONT_ZONE_PATTERN, FRONT_LEDS)

    for dev in {id(cpu_dev): cpu_dev, id(front_dev): front_dev}.values():
        set_direct_mode(dev)

    print("\nInitialising sensors:")
    cpu_sensor = CpuSensor(CPU_LEDS)
    gpu_sensor = GpuSensor(NVML_INDEX)

    cpu_signals  = [PeakHold(CPU_ATTACK_S, CPU_HOLD_S, CPU_RELEASE_S)
                    for _ in range(CPU_LEDS)]
    gpu_util_sig = PeakHold(BAR_ATTACK_S,  BAR_HOLD_S,  BAR_RELEASE_S)
    gpu_temp_sig = PeakHold(TEMP_ATTACK_S, TEMP_HOLD_S, TEMP_RELEASE_S)

    stop = {"flag": False}
    signal_module.signal(signal_module.SIGINT,  lambda *_: stop.update(flag=True))
    signal_module.signal(signal_module.SIGTERM, lambda *_: stop.update(flag=True))

    period = 1.0 / UPDATE_HZ
    debug_period = (1.0 / DEBUG_HZ) if (verbose and DEBUG_HZ > 0) else float("inf")
    last_debug = 0.0
    last = time.monotonic()
    last_cpu_colors = None
    last_front_colors = None

    print(f"\nRunning at {UPDATE_HZ} Hz. Ctrl-C to stop.")
    print(f"  CPU envelope: attack={CPU_ATTACK_S}s hold={CPU_HOLD_S}s release={CPU_RELEASE_S}s")
    print(f"  Bar envelope: attack={BAR_ATTACK_S}s hold={BAR_HOLD_S}s release={BAR_RELEASE_S}s")
    if not verbose:
        print("  (silent mode; pass --verbose for periodic sensor dumps)")
    print()

    try:
        while not stop["flag"]:
            now = time.monotonic()
            dt  = now - last
            last = now

            # Sample sensors -> feed signals.
            cpu_raw = cpu_sensor.read()
            for sig, raw in zip(cpu_signals, cpu_raw):
                sig.update(raw, now, dt)
            util_raw, temp_raw = gpu_sensor.read()
            gpu_util_sig.update(util_raw, now, dt)
            gpu_temp_sig.update(temp_raw, now, dt)

            # Compose strips.
            cpu_colors = composite([
                per_led([s.value for s in cpu_signals], CPU_GRADIENT),
            ], CPU_LEDS)

            front_colors = composite([
                fill(gradient(TEMP_GRADIENT, gpu_temp_sig.value), FRONT_LEDS),
                bar(gpu_util_sig.value, PURPLE, FRONT_LEDS,
                    top_at=0, reserve=FRONT_TEMP_RESERVE),
            ], FRONT_LEDS)

            # Only push when something actually changed.
            if cpu_colors != last_cpu_colors:
                cpu_zone.set_colors(cpu_colors, fast=True)
                last_cpu_colors = cpu_colors
            if front_colors != last_front_colors:
                front_zone.set_colors(front_colors, fast=True)
                last_front_colors = front_colors

            if now - last_debug >= debug_period:
                last_debug = now
                cpu_raw_s = " ".join(f"{x:.2f}" for x in cpu_raw)
                cpu_env_s = " ".join(f"{s.value:.2f}" for s in cpu_signals)
                print(
                    f"cpu raw=[{cpu_raw_s}] env=[{cpu_env_s}] | "
                    f"gpu util={util_raw:.2f}->{gpu_util_sig.value:.2f} "
                    f"temp={temp_raw*100:.0f}C->{gpu_temp_sig.value*100:.0f}C"
                )

            elapsed = time.monotonic() - now
            time.sleep(max(0.0, period - elapsed))
    finally:
        print("\nStopping; clearing zones.")
        black = RGBColor(0, 0, 0)
        for zone in (cpu_zone, front_zone):
            try:
                zone.set_colors([black] * len(zone.leds), fast=True)
            except Exception:
                pass
        gpu_sensor.close()
        try:
            client.disconnect()
        except Exception:
            pass


if __name__ == "__main__":
    p = argparse.ArgumentParser(description="OpenRGB workstation lighting controller.")
    p.add_argument("-v", "--verbose", action="store_true",
                   help="print periodic sensor/envelope state (default: silent, "
                        "to keep journalctl quiet when run as a service)")
    args = p.parse_args()
    sys.exit(main(verbose=args.verbose))
