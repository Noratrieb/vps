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
  ];
}
