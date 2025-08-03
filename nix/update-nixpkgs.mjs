import fs from "node:fs/promises";

const path = `${import.meta.dirname}/nixpkgs.json`;
const nixpkgs = JSON.parse(await fs.readFile(path));

const res = await fetch(
  `https://api.github.com/repos/NixOS/nixpkgs/commits/${nixpkgs.channel}`
);

if (!res.ok) {
  throw new Error(
    `get commit for ${name}: ${res.status} - ${await res.text()}`
  );
}

const body = await res.json();

if (body.sha !== nixpkgs.commit) {
  nixpkgs.commit = body.sha;
  nixpkgs.lastUpdated = new Date().toISOString();

  await fs.writeFile(path, JSON.stringify(nixpkgs, null, 2) + "\n");
}
