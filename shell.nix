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
    python311Packages.zstandard
    python311Packages.brotli
    (import (builtins.fetchTarball "https://github.com/ryantm/agenix/archive/531beac616433bac6f9e2a19feb8e99a22a66baf.tar.gz") { }).agenix
  ];
}
