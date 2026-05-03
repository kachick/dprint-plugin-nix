use schemars::{JsonSchema, schema_for};
use serde::Serialize;

#[derive(Clone, Serialize)]
#[serde(rename_all = "camelCase")]
#[derive(JsonSchema)]
pub struct Configuration {
    pub line_width: u32,
    pub indent_width: u8,
}

pub fn generate_json_schema() -> String {
    let schema = schema_for!(Configuration);
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
    }
}
