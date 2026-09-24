// SPDX-License-Identifier: MPL-2.0

#[cfg(feature = "schema")]
use schemars::{JsonSchema, schema_for};
use serde::Serialize;

#[derive(Clone, PartialEq, Eq, Debug, Serialize)]
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

impl Default for Configuration {
    fn default() -> Self {
        let nixfmt_defaults = nixfmt_rs::Options::default();
        Self {
            line_width: nixfmt_defaults.width as u32,
            indent_width: nixfmt_defaults.indent as u8,
        }
    }
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

        if let Some(properties) = obj.get_mut("properties").and_then(|p| p.as_object_mut()) {
            if let Ok(serde_json::Value::Object(defaults)) =
                serde_json::to_value(Configuration::default())
            {
                for (key, default_val) in defaults {
                    if let Some(prop) = properties.get_mut(&key).and_then(|p| p.as_object_mut()) {
                        prop.insert("default".to_string(), default_val);
                    }
                }
            }
        }
    }
    serde_json::to_string_pretty(&schema).unwrap()
}
