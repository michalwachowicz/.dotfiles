return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
    },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local has_blink, blink = pcall(require, "blink.cmp")
      if has_blink then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })

    end,
  },

  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        -- Core
        "lua_ls",
        "ts_ls",
        "html",
        "cssls",
        "jsonls",
        "eslint",
        "gopls",

        -- Extras
        "tailwindcss",
        "yamlls",
        "bashls",
        "docker_language_server",
        "docker_compose_language_service",
        "taplo",
        "marksman",
      },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "mason-org/mason.nvim",
    },
    opts = {
      ensure_installed = {
        -- JS / TS / frontend
        "prettier",
        "eslint_d",

        -- Lua
        "stylua",

        -- Go
        "gofumpt",
        "goimports",
        "golangci-lint",

        -- C#
        "csharpier",

        -- Shell
        "shellcheck",
        "shfmt",

        -- YAML / Docker / TOML / Markdown
        "yamlfmt",
        "hadolint",
        "taplo",
        "markdownlint",
      },
      run_on_start = true,
      debounce_hours = 12,
    },
  },

  {
    "saghen/blink.cmp",
    version = "*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "enter" },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = { auto_show = true },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
