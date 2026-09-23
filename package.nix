{
  lib,
  rustPlatform,
  rustc,
  dprint,
  writableTmpDirAsHomeHook,
  jsonschema-cli,
  yq-go,
  gnugrep,
}:

let
  wasmTarget = "wasm32-unknown-unknown";
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dprint-plugin-nix";
  version = with builtins; (fromTOML (readFile ./Cargo.toml)).package.version;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./src
      ./generate_json_schema
      ./Cargo.toml
      ./Cargo.lock
      ./LICENSE
      ./scripts
      ./tests
    ];
  };

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [
    rustc.llvmPackages.bintools # rust-lld
  ];

  cargoBuildFlags = [
    "--target=${wasmTarget}"
    "--package=dprint-plugin-nix"
  ];

  postBuild = ''
    cargo run --package=generate_json_schema > schema.json
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib" "$out/share"
    cp target/${wasmTarget}/release/dprint_plugin_nix.wasm "$out/lib/plugin.wasm"
    cp schema.json $out/share/

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    dprint
    writableTmpDirAsHomeHook
    jsonschema-cli
    yq-go
    gnugrep
  ];

  installCheckPhase = ''
    runHook preInstallCheck

    if [ -f "$src/scripts/test-jsonschema.bash" ]; then
      SCHEMA_PATH="$out/share/schema.json" VERSION='${finalAttrs.version}' bash "$src/scripts/test-jsonschema.bash"
    fi

    cd "$(mktemp --directory)"
    dprint check --allow-no-files --config-discovery=false --plugins "$out/lib/plugin.wasm"

    runHook preInstallCheck
  '';

  meta = {
    description = "Dprint Wasm plugin for Nix";
    homepage = "https://github.com/kachick/dprint-plugin-nix";
    license = lib.licenses.asl20;
  };
})
