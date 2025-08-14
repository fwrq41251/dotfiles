-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--select word
vim.keymap.set("n", "vv", "viw", { noremap = true, silent = true })
-- navigation
vim.keymap.set("n", ">", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<", "<C-u>zz", { noremap = true, silent = true })
-- add a new line below the current line
vim.keymap.set("n", "<CR>", "o<Esc>", { noremap = true, silent = true })
-- paste after the current line
vim.keymap.set("n", "<C-p>", "$p", { noremap = true, silent = true })
-- copy until the end of the line
vim.keymap.set("n", "Y", "y$", { noremap = true, silent = true })
-- paster and copy to clipboard
vim.keymap.set("x", "p", "pgvy", { noremap = true, silent = true })
-- move lines
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv", { noremap = true, silent = true })
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "ddkP", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "ddp", { noremap = true, silent = true })

vim.g.mapleader = " "

-- toggle relativenumber
-- vim.opt.relativenumber = true
-- vim.keymap.set("n", "<leader>l", function()
--   vim.opt.relativenumber = not vim.opt.relativenumber:get()
-- end, { noremap = true, silent = true, desc = "Toggle relative line numbers" })

-- Compile C/C++ files
vim.keymap.set(
  "n", -- Mode: Normal
  "<F5>",
  function()
    vim.cmd("write")
    vim.cmd("!gcc % -o %<")
  end,
  { noremap = true, silent = true, desc = "Compile C/C++ File" }
)
