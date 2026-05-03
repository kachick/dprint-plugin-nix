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
  pname = "dprint-plugin-nixfmt";
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
    yq-go
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p scripts # Ensure scripts directory exists for the build if not already there
    # If the script doesn't exist yet, we might need to skip or create a dummy for now
    if [ -f "$src/scripts/normalize_json_schema.bash" ]; then
      bash "$src/scripts/normalize_json_schema.bash" > schema.json
    else
      # Fallback: run it directly if possible
      cargo run --package generate_json_schema > schema.json
    fi
    cargo build --release --target=${wasmTarget}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib" "$out/share"
    cp target/${wasmTarget}/release/dprint_plugin_nixfmt.wasm "$out/lib/plugin.wasm"
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
    homepage = "https://github.com/kachick/dprint-plugin-nixfmt";
    license = lib.licenses.asl20;
  };
})
