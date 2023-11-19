{ pkgs ? import <nixpkgs> { } }: pkgs.mkShell {
  packages = with pkgs; [
    ansible
    ansible-lint
    certbot
    dig
    openssl
    caddy
    shellcheck
    git-crypt
  ];
}
