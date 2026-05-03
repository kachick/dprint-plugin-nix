fn main() {
    println!(
        "{}",
        dprint_plugin_nixfmt::configuration::generate_json_schema()
    );
}
