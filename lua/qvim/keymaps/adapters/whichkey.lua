---@class whichkey
local M = {}

---@class util
local util = require("qvim.keymaps.adapters.util")
local fn = require("qvim.utils.fn")
local shared_util = require("qvim.keymaps.util")
local constants = require("qvim.keymaps.constants")

-- constants
local rhs = constants.neovim_options_constants.rhs
local desc = constants.neovim_options_constants.desc
local group_binding_trigger = constants.binding_group_constants.key_binding_group
local group_name = constants.binding_group_constants.key_name
local group_bindings = constants.binding_group_constants.key_bindings
local group_opts = constants.binding_group_constants.key_options
local group_prefix = constants.binding_group_constants.key_prefix

---Formats a table of binidngs into a whichkey formfactor for fast processing.
---@param descriptors_t table
---@param binding_descriptor string
---@return table<table, table>
local function mutation_for_single_binding(descriptors_t, binding_descriptor)
	local keymaps = descriptors_t[binding_descriptor]
	local whichkey_mappings = {}
	local _opts = nil
	for lhs, opts in pairs(keymaps) do
		if not _opts then
			_opts = fn.shallow_table_copy(opts)
			_opts[rhs] = nil
			_opts[desc] = nil
		end

		whichkey_mappings[lhs] = { opts[rhs], opts[desc] }

		-- add members that are not included in the descriptors
		if keymaps[lhs][constants.neovim_options_constants.callback] then
			whichkey_mappings[lhs][constants.neovim_options_constants.callback] =
				keymaps[lhs][constants.neovim_options_constants.callback]
		end
	end
	return { whichkey_mappings, _opts }
end

local function mutation_for_group_binding(descriptors_t, group_descriptor)
	local group = descriptors_t[group_descriptor]
	local _group = fn.shallow_table_copy(group)
	local whichkey_group = {}
	local whichkey_group_bindings = {}
	local whichkey_group_opts = _group[group_opts]
	for lhs, opts in pairs(_group[group_bindings]) do
		whichkey_group_bindings[lhs] = { opts[rhs], opts[desc] }
		for key, value in pairs(opts) do
			if not (key == rhs or key == desc) then
				whichkey_group_bindings[lhs][key] = value
			end
		end
	end
	whichkey_group[_group[group_binding_trigger]] = whichkey_group_bindings
	whichkey_group[_group[group_binding_trigger]][group_name] = _group[group_name]

	whichkey_group_opts[group_prefix] = group[group_prefix]

	return { whichkey_group, whichkey_group_opts }
end

---Adapt keymaps for whichkey
---@param whichkey table The whichkey instance
---@param bindings table|nil
function M.adapt(whichkey, bindings)
	local _whichkey = qvim.integrations.whichkey
	whichkey.setup(_whichkey.options)

	bindings = bindings or qvim.keymaps
	for descriptor, _ in pairs(bindings) do
		shared_util.action_based_on_descriptor(descriptor, function()
			local proxy = util.make_proxy_mutation_table(bindings, mutation_for_single_binding)
			local mutated_keymappings = proxy[descriptor]
			whichkey.register(mutated_keymappings[#mutated_keymappings - 1], mutated_keymappings[#mutated_keymappings])
		end, function()
			local proxy = util.make_proxy_mutation_table(bindings, mutation_for_group_binding)
			local mutaged_group = proxy[descriptor]
			whichkey.register(mutaged_group[#mutaged_group - 1], mutaged_group[#mutaged_group])
		end)
	end
end

return M
