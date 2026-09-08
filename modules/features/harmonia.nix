{
  flake.nixosModules.harmonia = {
    services.harmonia.cache = {
      enable = true;
      # Generate key
      # $ nix-store --generate-binary-cache-key cache.yourdomain.tld-1 /var/lib/secrets/harmonia.secret /var/lib/secrets/harmonia.pub
      signKeyPaths = [ "/var/lib/secrets/harmonia.secret" ];
      settings.bind = "[::]:5000";
    };
  };
}
