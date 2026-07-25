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

      minipc = {
        A = [ (a "100.100.2.1") ]; # tailscale IP
      };
    in
    with hostsToDns;
    # vps{1,3,4} contains root noratrieb.dev
    combine [ dimetrodon vps3 triceratops ] // {
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
        "t-verify=dae826f2ae9f73a71cc247183616b6c9" # tuta verification
        "v=spf1 include:spf.tutanota.de -all"
      ];

      MX = [
        (ttl 60 (mx.mx 10 "mail.tutanota.de."))
      ];

      subdomains = {
        # --- NS records
        ns1 = dns1;
        ns2 = dns2;

        # --- ACME setup for caddy
        _acme-challenge.CNAME = [ (cname "_acme-challenge.nilstrieb.dev.") ];

        # --- website stuff
        blog = dimetrodon;
        www = dimetrodon;
        files = combine [ dimetrodon vps3 triceratops ] // {
          subdomains = {
            upload = dimetrodon;
          };
        };

        womangling = combine [ dimetrodon vps3 triceratops ];

        garage = combine [ dimetrodon vps2 vps3 triceratops ];

        matrix = vps2;

        # --- apps
        docker = dimetrodon;
        hugo-chat = dimetrodon // {
          subdomains.api = dimetrodon;
        };
        uptime = dimetrodon;
        does-it-build = triceratops;
        git = dimetrodon;
        olat = dimetrodon;
        hedgedoc = dimetrodon;

        std.CNAME = [ (cname "noratrieb.github.io.") ];

        # --- fun shit
        localhost.A = [ (a "127.0.0.1") ];
        newtest.TXT = [ "uwu it works" ];
        pronouns.TXT = [
          "she/her"
        ];
        sshhoneypot = ptilodus;

        # --- infra
        grafana = vps3;
        infra.subdomains = hostsToDns;

        # --- internal stuff
        internal.subdomains = builtins.listToAttrs (builtins.map
          (name: {
            inherit name;
            value = minipc // {
              subdomains = {
                _acme-challenge.CNAME = [ (cname "_acme-challenge.${name}.internal.noratrieb-acme-delegate.dev.") ];
              };
            };
          }) [ "immich" "paperless" "home-assistant" ]);

        # --- other verification
        _discord.TXT = [ "dh=e0f7e99c70c4ce17f7afcce3be8bfda9cd363843" ];
        _atproto.TXT = [ "did=did:plc:pqyzoyxk7gfcbxk65mjyncyl" ];

        # --- email
        _mta-sts.CNAME = [ (cname "mta-sts.tutanota.de.") ];
        mta-sts.CNAME = [ (cname "mta-sts.tutanota.de.") ];

        _domainkey.subdomains = {
          s1.CNAME = [ (cname "s1.domainkey.tutanota.de.") ];
          s2.CNAME = [ (cname "s2.domainkey.tutanota.de.") ];
        };
        _dmarc.TXT = [
          "v=DMARC1; p=quarantine; adkim=s"
        ];

        # retired
        bisect-rustc = dimetrodon;
      };
    };
in
pkgs.writeTextFile
{
  name = "noratrieb.dev.zone";
  text = pkgs.nix-dns.lib.toString "noratrieb.dev" data;
}
