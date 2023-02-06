local M = {}


if vim.fn.has "nvim-0.8" ~= 1 then
  vim.notify("Please upgrade your Neovim base installation. This configuration requires v0.8+", vim.log.levels.WARN)
  vim.wait(5000, function()
    ---@diagnostic disable-next-line: redundant-return-value
    return false
  end)
  vim.cmd "cquit"
end

-- Path based on os
local uv = vim.loop
local path_sep = uv.os_uname().version:match "Windows" and "\\" or "/"

---Join path segments that were passed as input
---@return string
function _G.join_paths(...)
  local result = table.concat({ ... }, path_sep)
  return result
end

_G.require_clean = require("qvim.utils.modules").require_clean
_G.require_safe = require("qvim.utils.modules").require_safe
_G.reload = require("qvim.utils.modules").reload

---Get the full path to `$QUANTUMVIM_CONFIG_DIR`
---@return string|nil
function _G.get_config_dir()
  local qvim_config_dir = os.getenv "QUANTUMVIM_CONFIG_DIR"
  if not qvim_config_dir then
    return vim.call("stdpath", "config")
  end
  return qvim_config_dir
end

---Get the full path to `$QUANTUMVIM_CACHE_DIR`
---@return string|nil
function _G.get_cache_dir()
  local qvim_cache_dir = os.getenv "QUANTUMVIM_CACHE_DIR"
  if not qvim_cache_dir then
    return vim.call("stdpath", "cache")
  end
  return qvim_cache_dir
end

---Initialize the `&runtimepath` variables and prepare for startup
---@return table
function M:init(base_dir)
  self.config_dir = get_config_dir()
  self.cache_dir = get_cache_dir()
  self.pack_dir = join_paths(self.runtime_dir, "site", "pack")
  self.lazy_install_dir = join_paths(self.pack_dir, "lazy", "opt", "lazy.nvim")

  ---@meta overridden to use QUANTUMVIM_CACHE_DIR instead, since a lot of plugins call this function internally
  ---NOTE: changes to "data" are currently unstable, see #2507
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.fn.stdpath = function(what)
    if what == "cache" then
      return _G.get_cache_dir()
    end
    return vim.call("stdpath", what)
  end

  ---Get the full path to QUANTUMVim's base directory
  ---@return string
  function _G.get_qvim_base_dir()
    return base_dir
  end

  print("Runtime dir: " .. self.runtime_dir)
  print("Config dir: " .. self.config_dir)
  require("qvim.integrations.loader"):init {
    package_root = self.pack_dir,
    install_path = self.lazy_install_dir,
  }

  require("qvim.config"):init()

  require("qvim.core.mason").bootstrap()

  return self
end

---Update qvimVim
---pulls the latest changes from github and, resets the startup cache
function M:update()
  require("qvim.utils.log"):info "Trying to update QuantumVim..."
  vim.schedule(function()
    reload("qvim.utils.hooks").run_pre_update()
    local ret = reload("qvim.utils.git").update_base_qvim()
    if ret then
      reload("qvim.utils.hooks").run_post_update()
    end
  end)
end

return M