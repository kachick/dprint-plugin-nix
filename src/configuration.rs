use schemars::{JsonSchema, schema_for};
use serde::Serialize;

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
#[derive(JsonSchema)]
pub struct Configuration {
    pub line_width: u32,
    pub indent_width: u8,
}

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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_json_schema() {
        let schema = generate_json_schema();
        assert!(schema.contains(r#""lineWidth":"#));
        assert!(schema.contains(r#""indentWidth":"#));
        assert!(schema.contains(r#""$id": "https://plugins.dprint.dev/kachick/nix/"#));
        assert!(schema.contains(r#""additionalProperties": false"#));
        assert!(!schema.contains(r#""title":"#));
        assert!(!schema.contains(r#""required":"#));
    }
}
