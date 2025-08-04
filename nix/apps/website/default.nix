{ pkgs, lib, my-projects-versions, ... }:
let
  website = import (fetchTarball "https://github.com/Noratrieb/website/archive/${my-projects-versions.website}.tar.gz");
  blog = fetchTarball "https://github.com/Noratrieb/blog/archive/${my-projects-versions.blog}.tar.gz";
  slides = fetchTarball "https://github.com/Noratrieb/slides/archive/${my-projects-versions.slides}.tar.gz";
  website-build = website { inherit pkgs slides blog; };
in
{
  services.caddy.virtualHosts = {
    "noratrieb.dev" = {
      logFormat = "";
      extraConfig = ''
        encode zstd gzip
        header -Last-Modified
        root * ${import ../../packages/caddy-static-prepare {
          name = "website";
          src = website-build;
          inherit pkgs lib;
        }}
        file_server {
          etag_file_extensions .sha256
          precompressed zstd gzip br
        }
      '';
    };
    "files.noratrieb.dev" = {
      logFormat = "";
      extraConfig = ''
        encode zstd gzip
        reverse_proxy * localhost:3902
      '';
    };
  };
}
