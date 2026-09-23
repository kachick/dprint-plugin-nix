# dprint-plugin-nix

[dprint](https://dprint.dev/) WASM plugin for Nix using [nixfmt-rs](https://github.com/Mic92/nixfmt-rs).

## Usage

Add the following to your `dprint.json`:

```json
{
  "plugins": [
    "https://plugins.dprint.dev/kachick/nix-v0.1.0.wasm"
  ]
}
```

## Configuration

```json
{
  "nix": {
    "lineWidth": 100,
    "indentWidth": 2
  }
}
```

## Acknowledgments

- Thanks to [nixfmt](https://github.com/NixOS/nixfmt) for the official Nix formatter.
- Thanks to [nixfmt-rs](https://github.com/Mic92/nixfmt-rs) for porting nixfmt to Rust, which makes it easy to use as a WASM plugin.
