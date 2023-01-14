local m_status_ok, lang_base = pcall(require, "user.languages.util.lang_base")
if not m_status_ok then 
  return
end

local python = lang_base:new{
  lsp_server = "pyright",
  formatter = { "black", "isort"},
  diagnostics = "pylint",
}

return python
