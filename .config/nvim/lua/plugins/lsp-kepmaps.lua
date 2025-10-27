-- lua/plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- ['*'] 是一个通配符，意味着这里的配置将应用于 *所有* LSP 服务器
      ["*"] = {
        keys = {
          { "K", "<cmd>lua vim.lsp.buf.definition()<CR>", desc = "Go to Definition" },
        },
      },
    },
  },
}
