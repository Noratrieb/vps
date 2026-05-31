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
    in
    with hostsToDns;
    {
      TTL = hour1;
      SOA = {
        nameServer = "ns.noratrieb-acme-delegate.dev.";
        adminEmail = "void@noratrieb.dev";
        serial = 2024072601;
      };

      CAA = [
        { issuerCritical = false; tag = "issue"; value = "letsencrypt.org"; }
        { issuerCritical = false; tag = "issue"; value = "sectigo.com"; }
      ];

      NS = [
        "ns.noratrieb-acme-delegate.dev."
      ];

      subdomains = {
        ns = dns1;
      };
    };
in
pkgs.writeTextFile {
  name = "noratrieb-acme-delegate.dev.zone";
  text = pkgs.nix-dns.lib.toString "noratrieb-acme-delegate.dev" data;
}
