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
      diplodocus = {
        A = [ "184.174.32.252" ];
      };
    in
    with hostsToDns;
    # point nilstrieb.dev to dimetrodon (retired)
    dimetrodon // {
      TTL = hour1;
      SOA = {
        nameServer = "ns.nilstrieb.dev.";
        adminEmail = "void@nilstrieb.dev";
        serial = 2024072601;
      };

      CAA = [
        { issuerCritical = false; tag = "issue"; value = "letsencrypt.org"; }
        { issuerCritical = false; tag = "issue"; value = "sectigo.com"; }
      ];

      NS = [
        "ns.nilstrieb.dev."
      ];

      subdomains = {
        ns = dns1;

        localhost.A = [ (a "127.0.0.1") ];

        # --- retired:
        bisect-rustc = dimetrodon;
        blog = dimetrodon;
        docker = dimetrodon;
        www = dimetrodon;
        uptime = dimetrodon;
        hugo-chat = dimetrodon // {
          subdomains.api = dimetrodon;
        };
        olat = dimetrodon;
        # ---

        # infra (legacy)
        inherit diplodocus;

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
