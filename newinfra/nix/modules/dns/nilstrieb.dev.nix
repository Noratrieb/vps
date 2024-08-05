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
    # point nilstrieb.dev to vps1 (retired)
    vps1 // {
      SOA = {
        nameServer = "ns1.nilstrieb.dev.";
        adminEmail = "void@nilstrieb.dev";
        serial = 2024072601;
      };

      TXT = [
        "protonmail-verification=86964dcc4994261eab23dbc53dad613b10bab6de"
        "v=spf1 include:_spf.protonmail.ch ~all"
      ];

      NS = [
        "ns1.nilstrieb.dev."
        "ns2.nilstrieb.dev."
      ];

      MX = with mx; [
        (mx 10 "mail.protonmail.ch.")
        (mx 20 "mailsec.protonmail.ch.")
      ];

      subdomains = {
        ns1 = dns1;
        ns2 = dns2;

        # apps
        cors-school = vps2 // {
          subdomains.api = vps2;
        };
        docker = vps2;
        olat = vps2;

        localhost.A = [ (a "127.0.0.1") ];

        # --- retired:
        bisect-rustc = vps1;
        blog = vps1;
        www = vps1;
        uptime = vps1;
        hugo-chat = vps1 // {
          subdomains.api = vps1;
        };
        # ---

        # infra (legacy)
        inherit vps1;
        inherit vps2;

        pronouns.TXT = [
          "TODO"
        ];

        bsky.subdomains.atproto.TXT = [ "did=did:plc:pqyzoyxk7gfcbxk65mjyncyl" ];
      };
    };
in
pkgs.writeTextFile {
  name = "nilstrieb.dev.zone";
  text = pkgs.nix-dns.lib.toString "nilstrieb.dev" data;
}
