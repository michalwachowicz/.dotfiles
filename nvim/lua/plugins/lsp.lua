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

      vim.lsp.config("roslyn_ls", {
        capabilities = vim.tbl_deep_extend("force", capabilities, {
          textDocument = {
            diagnostic = {
              dynamicRegistration = true,
            },
          },
        }),
        settings = {
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "openFiles",
            dotnet_compiler_diagnostics_scope = "openFiles",
          },
          ["csharp|completion"] = {
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true,
          },
        },
      })

      if vim.fn.executable("roslyn-language-server") == 1 or vim.fn.executable("Microsoft.CodeAnalysis.LanguageServer") == 1 then
        vim.lsp.enable("roslyn_ls")
      end
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
