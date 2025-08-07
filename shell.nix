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
        rev = "9edb1787864c4f59ae5074ad498b6272b3ec308d";
        hash = "sha256-NA/FT2hVhKDftbHSwVnoRTFhes62+7dxZbxj5Gxvghs=";
      })
      { }).agenix
  ];
}
