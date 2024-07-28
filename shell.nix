{ pkgs ? import <nixpkgs> { } }: pkgs.mkShell {
  packages = with pkgs; [
    ansible
    ansible-lint
    awscli
    certbot
    colmena
    dig
    openssl
    caddy
    shellcheck
    git-crypt
    opentofu
    wireguard-tools
    (import (builtins.fetchTarball "https://github.com/ryantm/agenix/archive/de96bd907d5fbc3b14fc33ad37d1b9a3cb15edc6.tar.gz") { }).agenix
  ];
}
