local utils = require("user.utils.util")

local null_ls = utils:require_module("null-ls")
local mason_null_ls = utils:require_module("mason-null-ls")
  
--:wlocal mason_available_sources = mason_null_ls:get_available_sources()

-- TODO apply proper diagnostics and formatting engines
-- null_ls.setup(
--     sources = {
--         -- all sources go here.
--     }
-- )
mason_null_ls.setup({
    ensure_installed = nil,
    automatic_installation = true,
    automatic_setup = true,
})
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
  debug = false,
  sources = {
    formatting.prettier.with({ extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" } }),
    formatting.black.with({ extra_args = { "--fast" } }),
    formatting.stylua,
    formatting.clang_format.with({ extra_args = { "--style=GNU" } }),
    diagnostics.flake8,
  },
})
