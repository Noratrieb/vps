import fs from "node:fs/promises";
import child_process from "node:child_process";

const fetchHash = (url) => {
  const res = child_process.execFileSync("nix", [
    "store",
    "prefetch-file",
    "--unpack",
    "--hash-type",
    "sha256",
    "--json",
    url,
  ]);
  const out = new TextDecoder().decode(res).trim();
  const { hash } = JSON.parse(out);
  return hash;
};

const path = `${import.meta.dirname}/my-projects.json`;
const projects = JSON.parse(await fs.readFile(path));

let hasChanges = false;

for (const [name, state] of Object.entries(projects)) {
  const { commit } = state;
  const res = await fetch(
    `https://api.github.com/repos/Noratrieb/${name}/commits/HEAD`
  );
  if (!res.ok) {
    throw new Error(
      `get commit for ${name}: ${res.status} - ${await res.text()}`
    );
  }
  const body = await res.json();
  const latestCommit = body.sha;

  if (commit !== latestCommit) {
    console.log(
      `${name} changed from ${commit} -> ${latestCommit} (${body.commit.message})`
    );

    const url = `https://github.com/Noratrieb/${name}/archive/${latestCommit}.tar.gz`;

    projects[name] = {
      commit: latestCommit,
      fetchFromGitHub: {
        owner: "Noratrieb",
        repo: name,
        rev: latestCommit,
        hash: fetchHash(url),
      },
    };
    hasChanges = true;
  }
}

if (hasChanges) {
  await fs.writeFile(path, JSON.stringify(projects, null, 2) + "\n");
}
