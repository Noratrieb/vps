{ pkgs ? import <nixpkgs> { } }: pkgs.mkShell {
  packages = with pkgs; [
    awscli
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
    nodejs
    (import
      (pkgs.fetchFromGitHub {
        owner = "ryantm";
        repo = "agenix";
        rev = "531beac616433bac6f9e2a19feb8e99a22a66baf";
        hash = "sha256-9P1FziAwl5+3edkfFcr5HeGtQUtrSdk/MksX39GieoA=";
      })
      { }).agenix
  ];
}
