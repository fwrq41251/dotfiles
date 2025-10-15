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
