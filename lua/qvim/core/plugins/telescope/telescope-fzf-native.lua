local log = require("qvim.log")

---@generic T
---@class telescope-fzf-native : core_meta_ext, telescope
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field extensions table<string> a list of extension url's
---@field conf_extensions table<string, T> instances of configured extensions
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field setup_ext fun(self: telescope-fzf-native)|nil overwrite the setup function in core_meta_ext
---@field url string neovim plugin url
local QV_EXT_PLUGIN_NAME_VAR = {
    enabled = true,
    name = nil,
    extensions = {},
    conf_extensions = {},
    options = {},
    keymaps = {},
    main = nil,
    setup_ext = nil, -- getmetatable(self).__index.setup_ext(self) to call generic setup with additional logic
    url = nil,
}

QV_EXT_PLUGIN_NAME_VAR.__index = QV_EXT_PLUGIN_NAME_VAR

return QV_EXT_PLUGIN_NAME_VAR
