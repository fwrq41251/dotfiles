return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local status = ""
    table.insert(opts.sections.lualine_x, 1, status)
    return opts
  end,
}
