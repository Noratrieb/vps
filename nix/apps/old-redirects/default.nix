{ ... }:
let
  permanent = [
    { from = "www.noratrieb.dev"; to = "noratrieb.dev"; }
    { from = "blog.noratrieb.dev"; to = "noratrieb.dev/blog"; }
    { from = "nilstrieb.dev"; to = "noratrieb.dev"; }
    { from = "www.nilstrieb.dev"; to = "noratrieb.dev"; }
    { from = "blog.nilstrieb.dev"; to = "noratrieb.dev/blog"; }
    { from = "bisect-rustc.nilstrieb.dev"; to = "bisect-rustc.noratrieb.dev"; }
    { from = "docker.nilstrieb.dev"; to = "docker.noratrieb.dev"; }
    { from = "hugo-chat.nilstrieb.dev"; to = "hugo-chat.noratrieb.dev"; }
    { from = "api.hugo-chat.nilstrieb.dev"; to = "api.hugo-chat.noratrieb.dev"; }
    { from = "uptime.nilstrieb.dev"; to = "uptime.noratrieb.dev"; }
    { from = "olat.nilstrieb.dev"; to = "olat.noratrieb.dev"; }
    { from = "olat.nilstrieb.dev:8088"; to = "olat.noratrieb.dev"; }
  ];
in
{
  services.caddy.virtualHosts = (
    {
      "bisect-rustc.noratrieb.dev" = {
        logFormat = "";
        extraConfig = "redir https://github.com/Noratrieb/cargo-bisect-rustc-service?tab=readme-ov-file#cargo-bisect-rustc-service";
      };
      "uptime.noratrieb.dev" = {
        logFormat = "";
        extraConfig = "redir https://github.com/Noratrieb/uptime?tab=readme-ov-file#uptime";
      };
    }
  ) // (
    builtins.listToAttrs (map
      (redirect: {
        name = redirect.from;
        value = {
          logFormat = "";
          extraConfig = "redir https://${redirect.to}{uri} permanent";
        };
      })
      permanent)
  );
}
