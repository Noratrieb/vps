{ pkgs, lib, name, src ? null, ... }: pkgs.stdenv.mkDerivation {
  inherit name src;

  buildInputs = with pkgs; [ python311 python311Packages.zstandard python311Packages.brotli ];

  buildPhase = ''
    mkdir -p $out
    cp -r $src/* $out/
    chmod -R +w $out
    ${lib.getExe pkgs.python311} ${./prepare.py} $out
    chmod -R -w $out
  '';
}
