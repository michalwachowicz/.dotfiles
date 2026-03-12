return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    keymaps = {
      file_panel = {
        ["o"] = function()
          local lib = require("diffview.lib")
          local view = lib.get_current_view()

          if view then
            local file = view.cur_entry.path
            vim.cmd("DiffviewClose")
            vim.cmd("edit " .. file)
          end
        end,
      },
    },
  },
}
