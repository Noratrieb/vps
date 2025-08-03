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

      combine = hosts: {
        A = lib.lists.flatten (map (host: if builtins.hasAttr "A" host then host.A else [ ]) hosts);
        AAAA = lib.lists.flatten (map (host: if builtins.hasAttr "AAAA" host then host.AAAA else [ ]) hosts);
      };
    in
    with hostsToDns;
    # vps{1,3,4} contains root noratrieb.dev
    combine [ vps1 vps3 vps4 ] // {
      TTL = hour1;
      SOA = {
        nameServer = "ns1.noratrieb.dev.";
        adminEmail = "void@noratrieb.dev";
        serial = 2024072601;
      };

      NS = [
        "ns1.noratrieb.dev."
        "ns2.noratrieb.dev."
      ];

      CAA = [
        { issuerCritical = false; tag = "issue"; value = "letsencrypt.org"; }
        { issuerCritical = false; tag = "issue"; value = "sectigo.com"; }
      ];

      TXT = [
        "protonmail-verification=09106d260e40df267109be219d9c7b2759e808b5"
        "v=spf1 include:_spf.protonmail.ch ~all"
      ];


      MX = [
        (mx.mx 10 "mail.protonmail.ch.")
        (mx.mx 20 "mailsec.protonmail.ch.")
      ];

      subdomains = {
        # --- NS records
        ns1 = dns1;
        ns2 = dns2;

        # --- website stuff
        blog = vps1;
        www = vps1;
        files = combine [ vps1 vps3 vps4 ] // {
          subdomains = {
            upload = vps1;
          };
        };

        # --- apps
        docker = vps1;
        hugo-chat = vps1 // {
          subdomains.api = vps1;
        };
        uptime = vps1;
        does-it-build = vps4;
        git = vps1;
        olat = vps1;

        std.CNAME = [ (cname "noratrieb.github.io.") ];

        # --- fun shit
        localhost.A = [ (a "127.0.0.1") ];
        newtest.TXT = [ "uwu it works" ];
        pronouns.TXT = [
          "she/her"
        ];
        sshhoneypot = vps5;

        # --- infra
        grafana = vps3;
        infra.subdomains = hostsToDns;

        # --- other verification
        _discord.TXT = [ "dh=e0f7e99c70c4ce17f7afcce3be8bfda9cd363843" ];
        _atproto.TXT = [ "did=did:plc:pqyzoyxk7gfcbxk65mjyncyl" ];

        # --- email
        _domainkey.subdomains = {
          protonmail.CNAME = [ (cname "protonmail.domainkey.deenxxi4ieo32na6brazky2h7bt5ezko6vexdbvbzzbtj6oj43kca.domains.proton.ch.") ];
          protonmail2.CNAME = [ (cname "protonmail2.domainkey.deenxxi4ieo32na6brazky2h7bt5ezko6vexdbvbzzbtj6oj43kca.domains.proton.ch.") ];
          protonmail3.CNAME = [ (cname "protonmail3.domainkey.deenxxi4ieo32na6brazky2h7bt5ezko6vexdbvbzzbtj6oj43kca.domains.proton.ch.") ];
        };
        _dmarc.TXT = [
          "v=DMARC1; p=quarantine"
        ];

        # retired
        bisect-rustc = vps1;
      };
    };
in
pkgs.writeTextFile
{
  name = "noratrieb.dev.zone";
  text = pkgs.nix-dns.lib.toString "noratrieb.dev" data;
}
