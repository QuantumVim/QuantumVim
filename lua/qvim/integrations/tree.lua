---The nvim-tree configuration file
local M = {}

local Log = require("qvim.log")

---Registers the global configuration scope for nvim-tree
function M:init()
	if _G.in_headless_mode() then
		return
	end
	local tree = {
		active = true,
		on_config_done = nil,
		keymaps = {
			["<leader>E"] = { desc = "Toggle nvim file tree", rhs = require("nvim-tree.api").tree.toggle },
		},
		options = {
			auto_reload_on_write = false,
			disable_netrw = false,
			hijack_cursor = false,
			hijack_netrw = true,
			hijack_unnamed_buffer_when_opening = false,
			sort_by = "name",
			root_dirs = {},
			prefer_startup_root = false,
			sync_root_with_cwd = true,
			reload_on_bufenter = false,
			respect_buf_cwd = false,
			on_attach = "default",
			remove_keymaps = false,
			select_prompts = false,
			view = {
				adaptive_size = false,
				centralize_selection = true,
				width = 40,
				hide_root_folder = false,
				side = "left",
				preserve_window_proportions = false,
				number = false,
				relativenumber = false,
				signcolumn = "yes",
				float = {
					enable = false,
					quit_on_focus_loss = true,
					open_win_config = {
						relative = "editor",
						border = "rounded",
						width = 30,
						height = 30,
						row = 1,
						col = 1,
					},
				},
			},
			renderer = {
				add_trailing = false,
				group_empty = false,
				highlight_git = true,
				full_name = false,
				highlight_opened_files = "none",
				root_folder_label = ":t",
				indent_width = 2,
				indent_markers = {
					enable = false,
					inline_arrows = true,
					icons = {
						corner = "└",
						edge = "│",
						item = "│",
						none = " ",
					},
				},
				icons = {
					webdev_colors = qvim.use_icons,
					git_placement = "before",
					padding = " ",
					symlink_arrow = " ➛ ",
					show = {
						file = qvim.use_icons,
						folder = qvim.use_icons,
						folder_arrow = qvim.use_icons,
						git = qvim.use_icons,
					},
					glyphs = {
						default = qvim.icons.ui.Text,
						symlink = qvim.icons.ui.FileSymlink,
						bookmark = qvim.icons.ui.BookMark,
						folder = {
							arrow_closed = qvim.icons.ui.TriangleShortArrowRight,
							arrow_open = qvim.icons.ui.TriangleShortArrowDown,
							default = qvim.icons.ui.Folder,
							open = qvim.icons.ui.FolderOpen,
							empty = qvim.icons.ui.EmptyFolder,
							empty_open = qvim.icons.ui.EmptyFolderOpen,
							symlink = qvim.icons.ui.FolderSymlink,
							symlink_open = qvim.icons.ui.FolderOpen,
						},
						git = {
							unstaged = qvim.icons.git.FileUnstaged,
							staged = qvim.icons.git.FileStaged,
							unmerged = qvim.icons.git.FileUnmerged,
							renamed = qvim.icons.git.FileRenamed,
							untracked = qvim.icons.git.FileUntracked,
							deleted = qvim.icons.git.FileDeleted,
							ignored = qvim.icons.git.FileIgnored,
						},
					},
				},
				special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
				symlink_destination = true,
			},
			hijack_directories = {
				enable = false,
				auto_open = true,
			},
			update_focused_file = {
				enable = true,
				debounce_delay = 15,
				update_root = true,
				ignore_list = {},
			},
			diagnostics = {
				enable = qvim.use_icons,
				show_on_dirs = false,
				show_on_open_dirs = true,
				debounce_delay = 50,
				severity = {
					min = vim.diagnostic.severity.HINT,
					max = vim.diagnostic.severity.ERROR,
				},
				icons = {
					hint = qvim.icons.diagnostics.BoldHint,
					info = qvim.icons.diagnostics.BoldInformation,
					warning = qvim.icons.diagnostics.BoldWarning,
					error = qvim.icons.diagnostics.BoldError,
				},
			},
			filters = {
				dotfiles = false,
				git_clean = false,
				no_buffer = false,
				custom = { "node_modules", "\\.cache" },
				exclude = {},
			},
			filesystem_watchers = {
				enable = true,
				debounce_delay = 50,
				ignore_dirs = {},
			},
			git = {
				enable = true,
				ignore = false,
				show_on_dirs = true,
				show_on_open_dirs = true,
				timeout = 200,
			},
			actions = {
				use_system_clipboard = true,
				change_dir = {
					enable = true,
					global = false,
					restrict_above_cwd = false,
				},
				expand_all = {
					max_folder_discovery = 300,
					exclude = {},
				},
				file_popup = {
					open_win_config = {
						col = 1,
						row = 1,
						relative = "cursor",
						border = "shadow",
						style = "minimal",
					},
				},
				open_file = {
					quit_on_open = false,
					resize_window = false,
					window_picker = {
						enable = true,
						picker = "default",
						chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
						exclude = {
							filetype = { "notify", "lazy", "qf", "diff", "fugitive", "fugitiveblame" },
							buftype = { "nofile", "terminal", "help" },
						},
					},
				},
				remove_file = {
					close_window = true,
				},
			},
			trash = {
				cmd = "trash",
				require_confirm = true,
			},
			live_filter = {
				prefix = "[FILTER]: ",
				always_show_folders = true,
			},
			tab = {
				sync = {
					open = false,
					close = false,
					ignore = {},
				},
			},
			notify = {
				threshold = vim.log.levels.INFO,
			},
			log = {
				enable = false,
				truncate = false,
				types = {
					all = false,
					config = false,
					copy_paste = false,
					dev = false,
					diagnostics = false,
					git = false,
					profile = false,
					watcher = false,
				},
			},
			system_open = {
				cmd = nil,
				args = {},
			},
		},
	}
	return tree
end

---Start telescope with as specified mode
---@param telescope_mode any
function M.start_telescope(telescope_mode)
	local node = require("nvim-tree.lib").get_node_at_cursor()
	local abspath = node.link_to or node.absolute_path
	local is_folder = node.open ~= nil
	local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
	require("telescope.builtin")[telescope_mode]({
		cwd = basedir,
	})
end

local function on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function telescope_find_files(_)
		require("qvim.integrations.nvim-tree").start_telescope("find_files")
	end

	local function telescope_live_grep(_)
		require("qvim.integrations.nvim-tree").start_telescope("live_grep")
	end

	api.config.mappings.default_on_attach(bufnr)

	local useful_keys = {
		["l"] = { callback = api.node.open.edit, desc = "Open" },
		["o"] = { api.node.open.edit, desc = "Open" },
		["<CR>"] = { api.node.open.edit, desc = "Open" },
		["v"] = { api.node.open.vertical, desc = "Open: Vertical Split" },
		["h"] = { api.node.navigate.parent_close, desc = "Close Directory" },
		["C"] = { api.tree.change_root_to_node, desc = "CD" },
		["gtg"] = { telescope_live_grep, desc = "Telescope Live Grep" },
		["gtf"] = { telescope_find_files, desc = "Telescope Find File" },
	}

	require("qvim.keymaps"):register(useful_keys, bufnr)
end

---The nvim-tree setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
	local status_ok, tree = pcall(reload, "nvim-tree")
	if not status_ok then
		Log:warn("The plugin '%s' could not be loaded.", tree)
		return
	end

	-- Implicitly update nvim-tree when project module is active
	if qvim.integrations.project.active then
		qvim.integrations.tree.options.respect_buf_cwd = true
		qvim.integrations.tree.options.update_cwd = true
		qvim.integrations.tree.options.update_focused_file.enable = true
		qvim.integrations.tree.options.update_focused_file.update_cwd = true
	end
	if qvim.integrations.tree.options.on_attach == "default" then
		qvim.integrations.tree.options.on_attach = on_attach
	end
	local _tree = qvim.integrations.tree
	tree.icons = _tree.glyphs
	tree.setup(_tree.options)

	if _tree.on_config_done then
		_tree.on_config_done()
	end
end

return M