---@generic T
---@class nvim-dap-ui : core_meta_ext, nvim-dap
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field extensions table<string> a list of extension url's
---@field conf_extensions table<string, T> instances of configured extensions
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: nvim-dap-ui, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: nvim-dap-ui)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: nvim-dap-ui, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local QV_EXT_PLUGIN_NAME_VAR = {
    enabled = true,
    name = nil,
    extensions = {},
    conf_extensions = {},
    options = {},
    keymaps = {},
    main = nil,
    on_setup_start = nil,
    setup_ext = nil,
    on_setup_done = nil,
    url = nil,
}

QV_EXT_PLUGIN_NAME_VAR.__index = QV_EXT_PLUGIN_NAME_VAR

return QV_EXT_PLUGIN_NAME_VAR
