#[cfg(feature = "schema")]
use schemars::{JsonSchema, schema_for};
use serde::Serialize;

#[derive(Clone, Serialize)]
#[cfg_attr(feature = "schema", derive(JsonSchema))]
#[serde(rename_all = "camelCase")]
// NOTE:
// dprint is a customizable formatter platform. We should expose options here
// when upstream `nixfmt_rs` provides new formatting settings.
//
// In particular, we want to support `strict` mode once it becomes available.
// As of nixfmt_rs 0.5.0, the upstream CLI accepts `--strict` as a no-op,
// and the library API does not support it yet.
pub struct Configuration {
    pub line_width: u32,
    pub indent_width: u8,
}

#[cfg(feature = "schema")]
#[must_use]
pub fn generate_json_schema() -> String {
    let mut schema = serde_json::to_value(schema_for!(Configuration)).unwrap();
    let version = env!("CARGO_PKG_VERSION");
    if let Some(obj) = schema.as_object_mut() {
        obj.remove("title");
        obj.remove("required");
        obj.insert(
            "$id".to_string(),
            serde_json::Value::String(format!(
                "https://plugins.dprint.dev/kachick/nix/{version}/schema.json"
            )),
        );
        obj.insert(
            "additionalProperties".to_string(),
            serde_json::Value::Bool(false),
        );
    }
    serde_json::to_string_pretty(&schema).unwrap()
}
