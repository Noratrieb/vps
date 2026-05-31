{ config, ... }: {
  age.secrets.knot_dns_acme_dns_01_key_envvar.file = ../../secrets/knot_dns_acme_dns_01_key_envvar.age;
  systemd.services.caddy.serviceConfig.EnvironmentFile = [ config.age.secrets.knot_dns_acme_dns_01_key_envvar.path ];

  services.caddy.globalConfig = ''
    acme_dns rfc2136 {
      key_name "acme-dns-01"
      key_alg "hmac-sha256"
      key "{$CADDY_DNS_RFC2136_KEY}"
      server "dns1.local:53"
    }
  '';
}
