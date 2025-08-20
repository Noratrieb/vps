{ ... }: {
  services.caddy.globalConfig = ''
    filesystem garage s3 {
      bucket noratrieb.dev
      region garage
      endpoint http://localhost:3900
      use_path_style
    }
  '';
  services.caddy.virtualHosts = {
    "noratrieb.dev" = {
      logFormat = "";
      extraConfig = ''
        encode zstd gzip
        header -Last-Modified

        header /blog/css/* Cache-Control "max-age=31540000, immutable"
        header /blog/fonts/* Cache-Control "max-age=31540000, immutable"

        @txt {
          path /
          not header Accept *text/html*
        }
        rewrite @txt /index.txt 

        file_server {
          fs garage
          # TODO: run precompress script
          # etag_file_extensions .sha256
          # precompressed zstd gzip br
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
