{ ... }: {
  services.prometheus = {
    enable = true;
    globalConfig = { };
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          { targets = [ "localhost:9090" ]; }
        ];
      }
      {
        job_name = "node";
        static_configs = [
          { targets = [ "vps1.local:9100" ]; }
          { targets = [ "vps3.local:9100" ]; }
          { targets = [ "vps4.local:9100" ]; }
          { targets = [ "vps5.local:9100" ]; }
        ];
      }
      {
        job_name = "caddy";
        static_configs = [
          { targets = [ "vps1.local:9010" ]; }
          { targets = [ "vps3.local:9010" ]; }
          { targets = [ "vps4.local:9010" ]; }
          { targets = [ "vps5.local:9010" ]; }
        ];
      }
    ];
  };
}
