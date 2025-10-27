-- lua/plugins/diffview.lua
return {
  "sindrets/diffview.nvim",
  -- lazy.nvim 的 `keys` 属性是定义快捷键的最佳位置
  keys = {
    -- <leader>dv: 打开 Diffview，比较当前分支与 main/master 的差异
    {
      "<leader>dv",
      "<cmd>DiffviewOpen<CR>",
      desc = "Diffview: Open (view all changes)",
    },
    -- <leader>df: 查看当前文件的历史版本
    {
      "<leader>df",
      "<cmd>DiffviewFileHistory %<CR>",
      desc = "Diffview: File History",
    },
  },
  -- (可选) 更多高级配置可以放在 cmd 中
  -- cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  -- config = function()
  --   require("diffview").setup({
  --     -- 在这里放置更复杂的自定义设置，但通常默认值就很好
  --   })
  -- end,
}
