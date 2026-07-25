let
  dns1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHT1stgiqG0CHwY66GXbduNJNNK5OR0e65GkisPwkcfb";
  dns2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDx/RO8KPR6kCKDZVFblRMp4G4weQegDHT1F8zGlUAid";
  dimetrodon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4Xj3TsDPStoHquTfOlyxShbA/kgMfQskKN8jpfiY4R";
  vps2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5s+zprxLgDhb6vxHgWjvzY8itKiWuKiX6QLGYo+OMu";
  vps3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvupo7d9YMZw56qhjB+tZPijxiG1dKChLpkOWZN0Y7C";
  triceratops = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP536z72AiOgRBvu6t11F2DQFnbspdz5x7rEwtOoFEay";
  ptilodus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWbIznvWQSqRF1E9Gv9y7JXMy3LZxMAWj6K0Nq91kyZ";
  minipc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINApZRrvK4RC1SU5m4OLbill7HZYPQtuvh/m/AB4q5dG";
in
{
  "widetom_bot_token.age".publicKeys = [ dimetrodon ];
  "widetom_config_toml.age".publicKeys = [ dimetrodon ];
  "docker_registry_password.age".publicKeys = [ dimetrodon ];
  "hugochat_db_password.age".publicKeys = [ dimetrodon ];
  "openolat_db_password.age".publicKeys = [ dimetrodon ];
  "minio_env_file.age".publicKeys = [ dimetrodon vps3 ];
  "garage_secrets.age".publicKeys = [ dimetrodon vps2 vps3 triceratops ptilodus ];
  "caddy_s3_key_secret.age".publicKeys = [ dimetrodon vps2 vps3 triceratops ptilodus ];
  "registry_htpasswd.age".publicKeys = [ dimetrodon ];
  "registry_s3_key_secret.age".publicKeys = [ dimetrodon ];
  "grafana_admin_password.age".publicKeys = [ vps3 ];
  "loki_env.age".publicKeys = [ vps3 ];
  "backup_s3_secret.age".publicKeys = [ dimetrodon vps2 vps3 triceratops ptilodus ];
  "s3_mc_admin_client.age".publicKeys = [ dimetrodon vps2 vps3 triceratops ptilodus ];
  "killua_env.age".publicKeys = [ dimetrodon ];
  "forgejo_s3_key_secret.age".publicKeys = [ dimetrodon ];
  "upload_files_s3_secret.age".publicKeys = [ dimetrodon ];
  "pyroscope_s3_secret.age".publicKeys = [ vps3 ];
  "restic_backup.age".publicKeys = [ dimetrodon vps2 vps3 triceratops ptilodus ];
  "generic_backup_password.age".publicKeys = [ dimetrodon vps2 vps3 triceratops ptilodus ];
  "website_s3_key_write.age".publicKeys = [ dimetrodon ]; # only used by Noratrieb/website GHA
  "does_it_build_private_key.age".publicKeys = [ triceratops ];
  "immich_secrets.age".publicKeys = [ minipc ];
  "paperless_env.age".publicKeys = [ minipc ];
  "hedgedoc_env.age".publicKeys = [ dimetrodon ];
  "knot_dns_acme_dns_01_key_config.age".publicKeys = [ dns1 dns2 ];
  "knot_dns_acme_dns_01_key_envvar.age".publicKeys = [ ptilodus minipc ];
  "wg_private_dns1.age".publicKeys = [ dns1 ];
  "wg_private_dns2.age".publicKeys = [ dns2 ];
  "wg_private_dimetrodon.age".publicKeys = [ dimetrodon ];
  "wg_private_vps2.age".publicKeys = [ vps2 ];
  "wg_private_vps3.age".publicKeys = [ vps3 ];
  "wg_private_triceratops.age".publicKeys = [ triceratops ];
  "wg_private_ptilodus.age".publicKeys = [ ptilodus ];
  "wg_private_minipc.age".publicKeys = [ minipc ];
}
