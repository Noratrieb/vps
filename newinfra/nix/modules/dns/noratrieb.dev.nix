# https://github.com/nix-community/dns.nix
{ pkgs, lib, networkingConfig, ... }:
let
  data = with pkgs.nix-dns.lib.combinators;
    let
      hour1 = 3600;
      hostsToDns = builtins.mapAttrs
        (name: { publicIPv4, publicIPv6, ... }:
          lib.optionalAttrs (publicIPv4 != null) { A = [ (ttl hour1 (a publicIPv4)) ]; } //
          lib.optionalAttrs (publicIPv6 != null) { AAAA = [ (ttl hour1 (aaaa publicIPv6)) ]; })
        networkingConfig;
      vps2 = {
        A = [ "184.174.32.252" ];
      };
    in
    with hostsToDns;
    # vps1 contains root noratrieb.dev
    vps1 // {
      SOA = {
        nameServer = "ns1.noratrieb.dev.";
        adminEmail = "void@noratrieb.dev";
        serial = 2024072601;
      };

      NS = [
        "ns1.noratrieb.dev."
        "ns2.noratrieb.dev."
      ];

      subdomains = {
        # --- NS records
        ns1 = dns1;
        ns2 = dns2;

        # --- website stuff
        blog.CNAME = map (ttl hour1) [ (cname "noratrieb.github.io") ];
        www = vps1;

        # --- legacy crap
        vps2 = vps2; # TODO REMOVE
        docker = vps2;

        # --- apps
        bisect-rustc = vps1;
        hugo-chat = vps1 // {
          subdomains.api = vps1;
        };
        uptime = vps1;

        # --- fun shit
        localhost.A = [ (a "127.0.0.1") ];
        newtest.TXT = [ "uwu it works" ];
        pronouns.TXT = [
          "she/her"
        ];

        # --- infra
        infra.subdomains = hostsToDns;
      };
    };
in
pkgs.writeTextFile
{
  name = "noratrieb.dev.zone";
  text = pkgs.nix-dns.lib.toString "noratrieb.dev" data;
}
