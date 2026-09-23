# dprint-plugin-nix

[dprint](https://dprint.dev/) WASM plugin for Nix using [nixfmt-rs](https://github.com/Mic92/nixfmt-rs).

## Installation

```bash
dprint config add 'kachick/nix'
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

## Motivation

- I prefer running formatters through dprint WASM plugins
- [`nix fmt` doesn't have check option](https://github.com/NixOS/nix/issues/6918)
- nixfmt needs treefmt (nixfmt-tree) to target Nix files in directories

## Acknowledgments

- Thanks to [nixfmt](https://github.com/NixOS/nixfmt) for the official Nix formatter.
- Thanks to [nixfmt-rs](https://github.com/Mic92/nixfmt-rs) for porting nixfmt to Rust, which makes it easy to use as a WASM plugin.
