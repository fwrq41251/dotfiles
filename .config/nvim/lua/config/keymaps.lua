-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- select word
vim.keymap.set("n", "vv", "viw", { noremap = true, silent = true })
-- paste after the current line
vim.keymap.set("n", "<C-p>", "$p", { noremap = true, silent = true })
-- copy until the end of the line
vim.keymap.set("n", "Y", "y$", { noremap = true, silent = true })
-- paster and copy to clipboard
vim.keymap.set("x", "p", "pgvy", { noremap = true, silent = true })
-- newline
vim.keymap.set("n", "<CR>", "o<Esc>", { noremap = true, silent = true })
vim.keymap.set("i", "<S-CR>", "<Esc>o", { noremap = true, silent = true })
vim.keymap.set("i", "<C-CR>", "<Esc>O", { noremap = true, silent = true })
-- show function signature
vim.keymap.set("i", "<C-k>", function()
  vim.lsp.buf.signature_help()
end, { noremap = true, silent = true })
-- debug
vim.api.nvim_set_keymap("n", "<F5>", ':lua require("dap").continue()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F8>", ':lua require("dap").step_over()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F7>", ':lua require("dap").step_into()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-F8>", ':lua require("dap").step_out()<CR>', { noremap = true, silent = true })
