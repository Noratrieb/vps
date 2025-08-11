let
  dns1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBKoyDczFntyQyWj47Z8JeewKcCobksd415WM1W56eS";
  dns2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZ1yLdDhI2Vou/9qrPIUP8RU8Sg0WxLI2njtP5hkdL7";
  vps1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4Xj3TsDPStoHquTfOlyxShbA/kgMfQskKN8jpfiY4R";
  vps2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5s+zprxLgDhb6vxHgWjvzY8itKiWuKiX6QLGYo+OMu";
  vps3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvupo7d9YMZw56qhjB+tZPijxiG1dKChLpkOWZN0Y7C";
  vps4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpoLgBTWj1BcNxXVdM26jDBZl+BCtUTj20Wv4sZdCHz";
  vps5 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWbIznvWQSqRF1E9Gv9y7JXMy3LZxMAWj6K0Nq91kyZ";
in
{
  "widetom_bot_token.age".publicKeys = [ vps1 ];
  "widetom_config_toml.age".publicKeys = [ vps1 ];
  "docker_registry_password.age".publicKeys = [ vps1 ];
  "hugochat_db_password.age".publicKeys = [ vps1 ];
  "openolat_db_password.age".publicKeys = [ vps1 ];
  "minio_env_file.age".publicKeys = [ vps1 vps3 ];
  "garage_secrets.age".publicKeys = [ vps1 vps2 vps3 vps4 vps5 ];
  "caddy_s3_key_secret.age".publicKeys = [ vps1 vps2 vps3 vps4 vps5 ];
  "registry_htpasswd.age".publicKeys = [ vps1 ];
  "registry_s3_key_secret.age".publicKeys = [ vps1 ];
  "grafana_admin_password.age".publicKeys = [ vps3 ];
  "loki_env.age".publicKeys = [ vps3 ];
  "backup_s3_secret.age".publicKeys = [ vps1 vps2 vps3 vps4 vps5 ];
  "s3_mc_admin_client.age".publicKeys = [ vps1 vps2 vps3 vps4 vps5 ];
  "killua_env.age".publicKeys = [ vps1 ];
  "forgejo_s3_key_secret.age".publicKeys = [ vps1 ];
  "upload_files_s3_secret.age".publicKeys = [ vps1 ];
  "pyroscope_s3_secret.age".publicKeys = [ vps3 ];
  "restic_backup.age".publicKeys = [ vps1 vps2 vps3 vps4 vps5 ];
  "generic_backup_password.age".publicKeys = [ vps1 vps2 vps3 vps4 vps5 ];
  "wg_private_dns1.age".publicKeys = [ dns1 ];
  "wg_private_dns2.age".publicKeys = [ dns2 ];
  "wg_private_vps1.age".publicKeys = [ vps1 ];
  "wg_private_vps2.age".publicKeys = [ vps2 ];
  "wg_private_vps3.age".publicKeys = [ vps3 ];
  "wg_private_vps4.age".publicKeys = [ vps4 ];
  "wg_private_vps5.age".publicKeys = [ vps5 ];
}
