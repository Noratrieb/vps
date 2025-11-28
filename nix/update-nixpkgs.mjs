import fs from "node:fs/promises";

const path = `${import.meta.dirname}/nixpkgs.json`;
const channels = JSON.parse(await fs.readFile(path));

for (const [channel, nixpkgs] of Object.entries(channels)) {
  const res = await fetch(
    `https://api.github.com/repos/NixOS/nixpkgs/commits/${channel}`
  );
  if (!res.ok) {
    throw new Error(
      `get commit for ${channel}: ${res.status} - ${await res.text()}`
    );
  }
  const body = await res.json();
  if (body.sha !== nixpkgs.commit) {
    nixpkgs.commit = body.sha;
    nixpkgs.lastUpdated = new Date().toISOString();
  }
}

await fs.writeFile(path, JSON.stringify(channels, null, 2) + "\n");
