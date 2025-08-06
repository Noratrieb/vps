import http from "node:http";

const server = http.createServer();
server
  .on("request", (req, res) => {
    fetch(
      "https://api.github.com/repos/Noratrieb/std-internal-docs/deployments"
    )
      .then(async (res) => {
        console.log(`Received response from GitHub: ${res.status}`);
        if (res.ok) {
          return res.json();
        } else {
          console.error(
            `Received error from GitHub: ${res.status}: ${await res.text()}`
          );
        }
      })
      .then((body) => {
        console.log(`Received body from GitHub`);
        const time =
          body?.[0]?.created_at && new Date(body[0].created_at).getTime();
        res
          .writeHead(time ? 200 : 500, {
            "Content-Type":
              "text/plain; version=0.0.4; charset=utf-8; escaping=underscores",
          })
          .end(
            time
              ? `std_internal_docs_last_deployment ${time}\n` +
                  `std_internal_docs_last_deployment_age ${new Date().getTime() - time}\n`
              : undefined
          );
      });
  })
  .listen(7846, "127.0.0.1", () => {
    console.log("Started the std.noratrieb.dev status exporter, lol");
  });
