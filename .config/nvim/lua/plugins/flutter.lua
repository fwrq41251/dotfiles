return {
  {
    "akinsho/flutter-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- 让选择设备的弹窗更好看
    },
    config = function()
      require("flutter-tools").setup({
        -- 如果 flutter doctor 找不到路径，取消下面这行的注释并填入你的路径
        -- flutter_path = "/home/winry/.local/share/mise/installs/flutter/stable/bin/flutter",

        ui = {
          border = "rounded",
          notification_style = "plugin",
        },
        decorations = {
          statusline = { app_version = true, device = true },
        },
        -- 开启 Widget 连线（类似 IDE 的视觉辅助）
        widget_guides = {
          enabled = true,
        },
        -- 开启自动闭合标签提示 (// Container)
        closing_tags = {
          highlight = "Comment",
          prefix = "// ",
          enabled = true,
        },
        lsp = {
          color = {
            enabled = false,
            background = true,
          },
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt",
          },
        },
        debugger = {
          enabled = true,
          run_via_dap = true,
          exception_breakpoints = {},
        },
      })
    end,
    keys = {
      {
        "<leader>Fs",
        function()
          require("flutter-tools.commands").run_command()
        end,
        desc = "Flutter Run",
      },
      {
        "<leader>Fq",
        function()
          require("flutter-tools.commands").quit()
        end,
        desc = "Flutter Quit",
      },
      {
        "<leader>Fr",
        function()
          require("flutter-tools.commands").reload()
        end,
        desc = "Flutter Hot Reload",
      },
      {
        "<leader>FR",
        function()
          require("flutter-tools.commands").restart()
        end,
        desc = "Flutter Hot Restart",
      },
      {
        "<leader>Fd",
        function()
          require("flutter-tools.devices").list_devices()
        end,
        desc = "Flutter Devices",
      },
      {
        "<leader>Fe",
        function()
          require("flutter-tools.emulators").list_emulators()
        end,
        desc = "Flutter Emulators",
      },
      {
        "<leader>FL",
        function()
          require("flutter-tools.dev_tools").open()
        end,
        desc = "Open DevTools",
      },
      { "<leader>Fl", ":FlutterLogToggle<cr>", desc = "Toggle Flutter Log" },
    },
  },
}
