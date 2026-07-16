{ ... }: {
  imports = [
    "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/de5708739256238fb912c62f03988815db89ec9a.tar.gz"}/module.nix" # v1.13.0 2026-07-16
  ];
}
