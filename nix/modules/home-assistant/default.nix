{ config, ... }: {
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"
      "fronius"
    ];
    config = {
      default_config = { };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "::1" ];
      };
    };
  };

  services.caddy.virtualHosts."home-assistant.internal.noratrieb.dev" = {
    extraConfig = ''
      tls {
        dns_challenge_override_domain "_acme-challenge.home-assistant.internal.noratrieb-acme-delegate.dev"
      }
      reverse_proxy * localhost:${builtins.toString config.services.home-assistant.config.http.server_port}
    '';
  };
}
