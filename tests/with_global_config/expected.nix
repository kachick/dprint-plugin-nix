{
    lib,
    rustPlatform,
}:
let
    wasmTarget = "wasm32-unknown-unknown";
in
rustPlatform.buildRustPackage
    (finalAttrs: {
        pname = "dprint-plugin-nix";
        version = "0.1.0";

        cargoBuildFlags = [
            "--target"
            wasmTarget
            "--package"
            "dprint-plugin-nix"
        ];

        meta = {
            description = "Dprint Wasm plugin for Nix";
            homepage = "https://github.com/kachick/dprint-plugin-nix";
            license = lib.licenses.mpl20;
        };
    })
