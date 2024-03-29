---@class bufferline : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: bufferline, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: bufferline)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: bufferline, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local bufferline = {
	enabled = true,
	name = nil,
	options = {
		options = {
			-- bufferline option configuration
			mode = "tabs", -- set to "tabs" to only show tabpages instead
			numbers = "none", --| "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string
			close_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
			right_mouse_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
			left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
			middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
			get_element_icon = function(element)
				-- element consists of {filetype: string, path: string, extension: string, directory: string}
				-- This can be used to change how bufferline fetches the icon
				-- for an element e.g. a buffer or a tab.
				-- e.g.
				local icon, hl =
					require("nvim-web-devicons").get_icon_by_filetype(
						element.filetype,
						{ default = false }
					)
				return icon, hl
			end,
			icon = "▎",
			--indicator = {
			--  icon = '▎', -- this should be omitted if indicator style is not 'icon'
			--  style = 'underline' -- | 'none' | 'icon'
			--},
			buffer_close_icon = "",
			modified_icon = "●",
			close_icon = "",
			left_trunc_marker = "",
			right_trunc_marker = "",
			--- name_formatter can be used to change the buffer's label in the bufferline.
			--- Please note some names can/will break the
			--- bufferline so use this at your discretion knowing that it has
			--- some limitations that will *NOT* be fixed.
			--name_formatter = function(buf) -- buf contains:
			-- name                | str        | the basename of the active file
			-- path                | str        | the full path of the active file
			-- bufnr (buffer only) | int        | the number of the active buffer
			-- buffers (tabs only) | table(int) | the numbers of the buffers in the tab
			-- tabnr (tabs only)   | int        | the "handle" of the tab, can be converted to its ordinal number using: `vim.api.nvim_tabpage_get_number(buf.tabnr)`
			--end,
			max_name_length = 18,
			max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
			truncate_names = true, -- whether or not tab names should be truncated
			tab_size = 18,
			diagnostics = "nvim_lsp", -- | "coc",
			diagnostics_update_in_insert = false,
			-- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
			--diagnostics_indicator = function(count, level, diagnostics_dict, context)
			--    return "("..count..")"
			--end,
			--- NOTE: this will be called a lot so don't do any heavy processing here
			--custom_filter = function(buf_number, buf_numbers)
			--    -- filter out filetypes you don't want to see
			--    if vim.bo[buf_number].filetype ~= "<i-dont-want-to-see-this>" then
			--        return true
			--    end
			--    -- filter out by buffer name
			--    if vim.fn.bufname(buf_number) ~= "<buffer-name-I-dont-want>" then
			--        return true
			--    end
			--    -- filter out based on arbitrary rules
			--    -- e.g. filter out vim wiki buffer from tabline in your work repo
			--    if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
			--        return true
			--    end
			--    -- filter out by it's index number in list (don't show first buffer)
			--    if buf_numbers[1] ~= buf_number then
			--        return true
			--    end
			--end,
			offsets = {
				{
					filetype = "NvimTree",
					text = "File Explorer", -- | function ,
					text_align = "left", -- | "center" | "right"
					separator = true,
				},
			},
			color_icons = true, --  whether or not to add the filetype icon highlights
			show_buffer_icons = true, -- disable filetype icons for buffers
			show_buffer_close_icons = false,
			show_close_icon = false,
			show_tab_indicators = false,
			show_duplicate_prefix = true, -- whether to show duplicate buffer prefix
			persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
			-- can also be a table containing 2 custom separators
			-- [focused and unfocused]. eg: { '|', '|' }
			separator_style = "thin", -- | "thick" | "slant" | { 'any', 'any' },
			enforce_regular_tabs = true,
			always_show_bufferline = true,
			hover = {
				enabled = true,
				delay = 200,
				reveal = { "close" },
			},
			--sort_by = 'insert_after_current' |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(
			--  buffer_a, buffer_b)
			--  -- add custom logic
			--  return buffer_a.modified > buffer_b.modified
			--end
		},
	},
	keymaps = {},
	main = "bufferline",
	on_setup_start = nil,
	---@param self bufferline
	setup = function(self)
		local mocha = require("catppuccin.palettes").get_palette("mocha")
		self.options.highlights =
			require("catppuccin.groups.integrations.bufferline").get({
				styles = { "italic", "bold" },
				custom = {
					all = {
						fill = { bg = "#000000" },
					},
					mocha = {
						background = { fg = mocha.text },
					},
					latte = {
						background = { fg = "#000000" },
					},
				},
			})
		require("qvim.core.util").call_super_setup(self)
	end,
	on_setup_done = nil,
	url = "https://github.com/akinsho/bufferline.nvim",
}

function bufferline.buf_kill(kill_command, bufnr, force)
	kill_command = kill_command or "bd"

	local bo = vim.bo
	local api = vim.api
	local fmt = string.format
	local fnamemodify = vim.fn.fnamemodify

	if bufnr == 0 or bufnr == nil then
		bufnr = api.nvim_get_current_buf()
	end

	local bufname = api.nvim_buf_get_name(bufnr)

	if not force then
		local warning
		if bo[bufnr].modified then
			warning = fmt(
				[[No write since last change for (%s)]],
				fnamemodify(bufname, ":t")
			)
		elseif api.nvim_buf_get_option(bufnr, "buftype") == "terminal" then
			warning = fmt([[Terminal %s will be killed]], bufname)
		end
		if warning then
			vim.ui.input({
				prompt = string.format(
					[[%s. Close it anyway? [y]es or [n]o (default: no): ]],
					warning
				),
			}, function(choice)
				if choice ~= nil and choice:match("ye?s?") then
					bufferline.buf_kill(kill_command, bufnr, true)
				end
			end)
			return
		end
	end

	-- Get list of windows IDs with the buffer to close
	local windows = vim.tbl_filter(function(win)
		return api.nvim_win_get_buf(win) == bufnr
	end, api.nvim_list_wins())

	if force then
		kill_command = kill_command .. "!"
	end

	-- Get list of active buffers
	local buffers = vim.tbl_filter(function(buf)
		return api.nvim_buf_is_valid(buf) and bo[buf].buflisted
	end, api.nvim_list_bufs())

	-- If there is only one buffer (which has to be the current one), vim will
	-- create a new buffer on :bd.
	-- For more than one buffer, pick the previous buffer (wrapping around if necessary)
	if #buffers > 1 and #windows > 0 then
		for i, v in ipairs(buffers) do
			if v == bufnr then
				local prev_buf_idx = i == 1 and #buffers or (i - 1)
				local prev_buffer = buffers[prev_buf_idx]
				for _, win in ipairs(windows) do
					api.nvim_win_set_buf(win, prev_buffer)
				end
			end
		end
	end

	-- Check if buffer still exists, to ensure the target buffer wasn't killed
	-- due to options like bufhidden=wipe.
	if api.nvim_buf_is_valid(bufnr) and bo[bufnr].buflisted then
		vim.cmd(string.format("%s %d", kill_command, bufnr))
	end
end

bufferline.__index = bufferline

return bufferline
