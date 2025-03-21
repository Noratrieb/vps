{ config, ... }:
let release = "nixos-24.11"; in
{
  age.secrets.mail_git_password_hashed.file = ../../secrets/mail_git_password_hashed.age;

  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
      sha256 = "05k4nj2cqz1c5zgqa0c6b8sp3807ps385qca74fgs6cdc415y3qw";
    })
  ];

  mailserver = {
    enable = true;
    fqdn = "mail.noratrieb.dev";
    domains = [ "git.noratrieb.dev" ];

    loginAccounts = {
      "git@git.noratrieb.dev" = {
        hashedPasswordFile = config.age.secrets.mail_git_password_hashed.path;
      };
    };
  };
}
