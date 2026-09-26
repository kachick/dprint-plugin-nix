# dprint-plugin-nix

[![npm version](https://img.shields.io/npm/v/@kachick/dprint-plugin-nix.svg)](https://www.npmjs.com/package/@kachick/dprint-plugin-nix) [![CI - Nix Status](https://github.com/kachick/dprint-plugin-nix/actions/workflows/nix.yml/badge.svg?branch=main)](https://github.com/kachick/dprint-plugin-nix/actions/workflows/nix.yml?query=branch%3Amain+)

[dprint](https://dprint.dev/) WASM plugin for Nix using [nixfmt-rs](https://github.com/Mic92/nixfmt-rs).

## Installation

```bash
dprint add kachick/nix
```

## Configuration

Empty works as default

```json
{
  "nix": {
  }
}
```

Customize if necessary

```json
{
  "nix": {
    "lineWidth": 100,
    "indentWidth": 2
  }
}
```

## Tips

To format Nix code block in markdown, use `tags` option in official plugin.

```bash
dprint add markdown
```

```json
{
  "markdown": {
    "tags": {
      "nix": "nix"
    }
  }
}
```

Runs on `nix fmt`, Replace nixfmt-tree with dprint

```nix
{
  formatter = forAllSystems (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    pkgs.writeShellScriptBin "dprint-fmt" ''
      exec "${lib.getExe pkgs.dprint}" fmt "$@"
    ''
  );
}
```

## Limitation

Because this plugin is updated after upstream nixfmt and nixfmt-rs, it will lag behind the latest upstream.\
Please do not use it for nixpkgs or [NixOS/](https://github.com/NixOS/) contributions, and use it only in personal repositories.

## Motivation

- I prefer running formatters through dprint WASM plugins
- [`nix fmt` doesn't have check option](https://github.com/NixOS/nix/issues/6918)
- nixfmt needs treefmt (nixfmt-tree) to target Nix files in directories
- Format Nix codeblock with the [markdown plugin](https://github.com/dprint/dprint-plugin-markdown)

## Acknowledgments

- Thanks to [nixfmt](https://github.com/NixOS/nixfmt) for the official Nix formatter.
- Thanks to [nixfmt-rs](https://github.com/Mic92/nixfmt-rs) for porting nixfmt to Rust, which makes it easy to use as a WASM plugin.
