# https://github.com/nix-community/dns.nix
{ pkgs, lib, networkingConfig, ... }:
let
  data = with pkgs.nix-dns.lib.combinators;
    let
      hour1 = 3600;
      hostsToDns = builtins.mapAttrs
        (name: { publicIPv4, publicIPv6, ... }:
          lib.optionalAttrs (publicIPv4 != null) { A = [ (a publicIPv4) ]; } //
          lib.optionalAttrs (publicIPv6 != null) { AAAA = [ (aaaa publicIPv6) ]; })
        networkingConfig;
      vps2 = {
        A = [ "184.174.32.252" ];
      };
    in
    with hostsToDns;
    # point nilstrieb.dev to vps1 (retired)
    vps1 // {
      TTL = hour1;
      SOA = {
        nameServer = "ns1.nilstrieb.dev.";
        adminEmail = "void@nilstrieb.dev";
        serial = 2024072601;
      };

      CAA = [
        { issuerCritical = false; tag = "issue"; value = "letsencrypt.org"; }
        { issuerCritical = false; tag = "issue"; value = "sectigo.com"; }
      ];

      NS = [
        "ns1.nilstrieb.dev."
        "ns2.nilstrieb.dev."
      ];

      subdomains = {
        ns1 = dns1;
        ns2 = dns2;

        # apps
        cors-school = vps2 // {
          subdomains.api = vps2;
        };
        olat = vps2;

        localhost.A = [ (a "127.0.0.1") ];

        # --- retired:
        bisect-rustc = vps1;
        blog = vps1;
        docker = vps1;
        www = vps1;
        uptime = vps1;
        hugo-chat = vps1 // {
          subdomains.api = vps1;
        };
        # ---

        # infra (legacy)
        inherit vps2;

        pronouns.TXT = [
          "she/her"
        ];
      };
    };
in
pkgs.writeTextFile {
  name = "nilstrieb.dev.zone";
  text = pkgs.nix-dns.lib.toString "nilstrieb.dev" data;
}
