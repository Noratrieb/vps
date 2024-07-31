{ name, config, networkingConfig, ... }:
let
  wgSettings = (builtins.getAttr name networkingConfig).wg;
  listenPort = 51820;
in
{
  # TODO: put the actual setup here.
  networking.hosts = {
    "10.0.0.1" = [ "vps1.local" ];
    "10.0.0.3" = [ "vps3.local" ];
  };

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
