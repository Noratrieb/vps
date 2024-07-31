{ name, config, networkingConfig, ... }:
let
  wgSettings = (builtins.getAttr name networkingConfig).wg;
  listenPort = 51820;
in
{
  # Map from $HOST.local to the private IP.
  networking.hosts =
    let
      hostsEntries = map
        (host:
          let hostConfig = builtins.getAttr host networkingConfig; in
          if builtins.hasAttr "wg" hostConfig then {
            name = hostConfig.wg.privateIP;
            value = [ "${host}.local" ];
          } else null)
        (builtins.attrNames networkingConfig);
      wgHostEntries = builtins.filter (entry: entry != null) hostsEntries;
    in
    builtins.listToAttrs wgHostEntries;

  age.secrets.wg_private.file = ../../secrets/wg_private_${name}.age;
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "${wgSettings.privateIP}/24" ];
      inherit listenPort;

      privateKeyFile = config.age.secrets.wg_private.path;
      peers = map
        (peer:
          let peerConfig = (builtins.getAttr peer networkingConfig).wg;
          in {
            inherit (peerConfig) publicKey;
            endpoint = "${peer}.infra.noratrieb.dev:${toString listenPort}";
            allowedIPs = [ "${peerConfig.privateIP}/32" ];
          }
        )
        wgSettings.peers;
    };
  };
}
