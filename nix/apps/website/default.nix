{ pkgs, lib, my-projects-versions, ... }:
let
  website = import (pkgs.fetchFromGitHub my-projects-versions.website.fetchFromGitHub);
  blog = pkgs.fetchFromGitHub my-projects-versions.blog.fetchFromGitHub;
  slides = pkgs.fetchFromGitHub my-projects-versions.slides.fetchFromGitHub;
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
