local nlspsettings = require("nlspsettings")

nlspsettings.setup({
	config_home = vim.fn.stdpath("config") .. "/lua/languages/lsp/settings",
	append_default_schemas = true,
	local_settings_root_markers = { ".git" },
	loader = "json",
	local_settings_dir = ".nlsp-settings",
})
