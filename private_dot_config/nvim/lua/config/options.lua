-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- Do not format by default
vim.g.autoformat = false

-- Do not show diagnostic by default
vim.diagnostic.enable(false)

-- Search always from the initialized directory
vim.g.root_spec = { "cwd" }
