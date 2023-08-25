{
  description = "VPS setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forAllSystems ({ pkgs }: {
        default =
          let
            python = pkgs.python311;
            pythonPkgs = python.withPackages (ps: with ps; [
              virtualenv
              pip
            ]);
          in
          pkgs.mkShell {
            packages = with pkgs; [
              # Python plus helper tools
              pythonPkgs
              ansible
              ansible-lint
              certbot
              dig
              openssl
            ];
          };
      });
    };
}
