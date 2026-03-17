return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
        callback = function(args)
          local buf = args.buf
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end

          if vim.bo[buf].buftype ~= "" or vim.bo[buf].filetype == "neo-tree" then
            return
          end

          local path = vim.api.nvim_buf_get_name(buf)
          if path ~= "" then
            vim.g.neotree_last_file_path = vim.fs.normalize(path)
          end
        end,
      })
    end,
    opts = {
      filesystem = {
        components = {
          name = function(config, node, state)
            local name_component = require("neo-tree.sources.common.components").name
            local rendered = name_component(config, node, state)

            if node.type ~= "file" then
              return rendered
            end

            local current = vim.g.neotree_last_file_path
            if type(current) ~= "string" or current == "" then
              return rendered
            end

            local node_path = node.path
            if type(node_path) ~= "string" or node_path == "" then
              return rendered
            end

            local function normalize(path)
              return vim.fs.normalize(path)
            end

            local current_norm = normalize(current)
            local node_norm = normalize(node_path)

            if current_norm == node_norm then
              rendered.highlight = "NeoTreeFileNameOpened"
              return rendered
            end

            local current_real = vim.uv.fs_realpath(current_norm)
            local node_real = vim.uv.fs_realpath(node_norm)
            if type(current_real) == "string" and type(node_real) == "string" and current_real == node_real then
              rendered.highlight = "NeoTreeFileNameOpened"
            end

            return rendered
          end,
        },
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
      },
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_configs = {
        indent = {
          with_expanders = true,
        },
        git_status = {
          symbols = {
            added = "",
            deleted = "",
            modified = "",
            renamed = "➜",
            untracked = "★",
            ignored = "◌",
            unstaged = "!",
            staged = "✓",
            conflict = "✗",
          },
        },
        name = {
          highlight_opened_files = false,
        },
      },
      window = {
        position = "left",
        width = 32,
      },
    },
  },
}
