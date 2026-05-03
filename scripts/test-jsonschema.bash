#!/usr/bin/env bash

set -euxo pipefail

export SCHEMA_PATH="${SCHEMA_PATH:-/dev/stdin}"

jsonschema-cli "$SCHEMA_PATH" --instance <(yq --output-format json '.nix' ./tests/default/dprint.json)
grep --quiet --fixed-strings "$VERSION" "$SCHEMA_PATH"
