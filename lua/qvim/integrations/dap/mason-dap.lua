---The mason-nvim-dap configuration file of the dap plugin
local M = {}

local Log = require("qvim.integrations.log")

---Registers the global configuration scope for dap
function M:config()
	qvim.integrations.dap.mason_nvim_dap = {
		active = true,
		on_config_done = nil,
		keymaps = {},
		options = {
			-- mason setup is handled by lang section
			automatic_installation = false,
			ensure_installed = { "python", "mix_task", "cppdbg", "codelldb", "chrome", "bash", "node2" },
			handlers = {
			},
		},
	}
end

---The mason-nvim-dap setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
	local status_ok, mason_nvim_dap = pcall(reload, "mason-nvim-dap")
	if not status_ok then
		Log:warn(string.format("The extension '%s' could not be loaded.", mason_nvim_dap))
		return
	end

	local _dap_mason_nvim_dap = qvim.integrations.dap.mason_nvim_dap
	mason_nvim_dap.setup(_dap_mason_nvim_dap.options)

	if _dap_mason_nvim_dap.on_config_done then
		_dap_mason_nvim_dap.on_config_done()
	end
end

return M
