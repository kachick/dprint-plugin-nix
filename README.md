# dprint-plugin-nixfmt

[dprint](https://dprint.dev/) WASM plugin for Nix using [nixfmt-rs](https://github.com/Mic92/nixfmt-rs).

## Usage

Add the following to your `dprint.json`:

```json
{
  "plugins": [
    "https://plugins.dprint.dev/kachick/nixfmt-v0.1.0.wasm"
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
