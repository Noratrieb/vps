let
  vps1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOixcV3SGAWRCMYYn+ybioFSBhpfkYzSU1nX+g6e5jI5";
in
{
  "widetom_bot_token.age".publicKeys = [ vps1 ];
  "widetom_config_toml.age".publicKeys = [ vps1 ];
  "docker_registry_password.age".publicKeys = [ vps1 ];
  "minio_env_file.age".publicKeys = [ vps1 ];
}
