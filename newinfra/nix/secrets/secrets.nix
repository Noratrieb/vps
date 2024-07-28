let
  vps1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4Xj3TsDPStoHquTfOlyxShbA/kgMfQskKN8jpfiY4R";
  vps3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvupo7d9YMZw56qhjB+tZPijxiG1dKChLpkOWZN0Y7C";
in
{
  "widetom_bot_token.age".publicKeys = [ vps1 ];
  "widetom_config_toml.age".publicKeys = [ vps1 ];
  "docker_registry_password.age".publicKeys = [ vps1 ];
  "minio_env_file.age".publicKeys = [ vps1 vps3 ];
  "wg_private_vps1.age".publicKeys = [ vps1 ];
  "wg_private_vps3.age".publicKeys = [ vps3 ];
}
