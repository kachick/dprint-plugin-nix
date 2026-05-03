use dprint_core::configuration::{ConfigKeyMap, GlobalConfiguration, get_value};
use dprint_core::plugins::{
    FileMatchingInfo, FormatResult, PluginInfo, PluginResolveConfigurationResult,
    SyncFormatRequest, SyncHostFormatRequest, SyncPluginHandler,
};

use anyhow::Result;

pub mod configuration;
use configuration::Configuration;

#[derive(Default)]
pub struct NixfmtPluginHandler;

impl SyncPluginHandler<Configuration> for NixfmtPluginHandler {
    fn plugin_info(&mut self) -> PluginInfo {
        let version = env!("CARGO_PKG_VERSION").to_string();
        PluginInfo {
            name: env!("CARGO_PKG_NAME").to_string(),
            version: version.clone(),
            config_key: "nix".to_string(),
            help_url: "https://github.com/kachick/dprint-plugin-nixfmt".to_string(),
            config_schema_url: format!(
                "https://plugins.dprint.dev/kachick/nixfmt/{}/schema.json",
                version
            ),
            update_url: Some("https://plugins.dprint.dev/kachick/nixfmt/latest.json".to_string()),
        }
    }

    fn license_text(&mut self) -> String {
        std::str::from_utf8(include_bytes!("../LICENSE"))
            .unwrap()
            .into()
    }

    fn resolve_config(
        &mut self,
        config: ConfigKeyMap,
        global_config: &GlobalConfiguration,
    ) -> PluginResolveConfigurationResult<Configuration> {
        let mut config = config;
        let mut diagnostics = Vec::new();
        let nixfmt_defaults = nixfmt_rs::Options::default();

        let line_width = get_value(
            &mut config,
            "lineWidth",
            global_config
                .line_width
                .unwrap_or(nixfmt_defaults.width as u32),
            &mut diagnostics,
        );

        let indent_width = get_value(
            &mut config,
            "indentWidth",
            global_config
                .indent_width
                .unwrap_or(nixfmt_defaults.indent as u8),
            &mut diagnostics,
        );

        PluginResolveConfigurationResult {
            config: Configuration {
                line_width,
                indent_width,
            },
            diagnostics,
            file_matching: FileMatchingInfo {
                file_extensions: vec!["nix".to_string()],
                file_names: vec![],
            },
        }
    }

    fn format(
        &mut self,
        request: SyncFormatRequest<Configuration>,
        _format_with_host: impl FnMut(SyncHostFormatRequest) -> FormatResult,
    ) -> FormatResult {
        if request.range.is_some() {
            return Ok(None);
        }

        let text = String::from_utf8_lossy(&request.file_bytes);
        let mut options = nixfmt_rs::Options::default();
        options.width = request.config.line_width as usize;
        options.indent = request.config.indent_width as usize;

        match nixfmt_rs::format_with(text.as_ref(), &options) {
            Ok(result) if result != text => Ok(Some(result.into())),
            Ok(_) => Ok(None),
            Err(err) => Err(anyhow::anyhow!(
                "Formatting failed: {}",
                nixfmt_rs::format_error(text.as_ref(), None, &err)
            )),
        }
    }

    fn check_config_updates(
        &self,
        _message: dprint_core::plugins::CheckConfigUpdatesMessage,
    ) -> Result<Vec<dprint_core::plugins::ConfigChange>> {
        Ok(Vec::new())
    }
}

#[cfg(target_arch = "wasm32")]
use dprint_core::generate_plugin_code;

#[cfg(target_arch = "wasm32")]
generate_plugin_code!(NixfmtPluginHandler, NixfmtPluginHandler, Configuration);
