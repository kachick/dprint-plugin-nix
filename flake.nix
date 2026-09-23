{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      lib = nixpkgs.lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      # This project implements a dprint plugin for nixfmt-rs.
      # For its own Nix files, it uses the upstream nixfmt directly to avoid bootstrapping issues
      # and keep the development environment stable without depending on the yet-to-be-built plugin.
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          dprint-plugin-nix = pkgs.callPackage ./package.nix { };
          default = dprint-plugin-nix;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.dprint-plugin-nix ];

            buildInputs = with pkgs; [
              bashInteractive
              findutils # xargs
              diffutils # for E2E test
              nixfmt
              nixd
              go-task
              typos
              zizmor
              treefmt

              wasm-tools

              # buildRustPackage does not enable these
              rust-analyzer
              clippy
            ];

            nativeBuildInputs = with pkgs; [
              rustc.llvmPackages.bintools # rust-lld
            ];

            env = {
              # Needed for avoiding "error: linker `rust-lld` not found".
              # Adding packages like binutils is not enough
              #
              # https://github.com/NixOS/nixpkgs/issues/70238
              CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER = "lld";

              # Workaround for rust-analyzer error
              RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
            };
          };
        }
      );
    };
}
