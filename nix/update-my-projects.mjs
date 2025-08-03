import fs from "node:fs/promises";

const path = `${import.meta.dirname}/my-projects.json`;
const projects = JSON.parse(await fs.readFile(path));

let hasChanges = false;

for (const [name, commit] of Object.entries(projects)) {
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
    projects[name] = latestCommit;
    hasChanges = true;
  }
}

if (hasChanges) {
  await fs.writeFile(path, JSON.stringify(projects, null, 2) + "\n");
}
