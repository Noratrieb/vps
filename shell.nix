{ pkgs ? import <nixpkgs> { } }: pkgs.mkShell {
  packages = with pkgs; [
    ansible
    ansible-lint
    awscli
    certbot
    dig
    openssl
    caddy
    shellcheck
    git-crypt
    opentofu
  ];
}
