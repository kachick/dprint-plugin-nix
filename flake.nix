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
          dprint-plugin-nixfmt = pkgs.callPackage ./package.nix { };
          default = dprint-plugin-nixfmt;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.dprint-plugin-nixfmt ];

            buildInputs = with pkgs; [
              bashInteractive
              findutils # xargs
              diffutils # for E2E test
              nixfmt
              nixd
              go-task
              typos
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
              CARGO_BUILD_TARGET = "wasm32-unknown-unknown";
              CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER = "lld";
              RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
            };
          };
        }
      );
    };
}
