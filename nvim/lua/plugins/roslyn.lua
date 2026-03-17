return {
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    opts = {
      filewatching = "auto",
    },
    config = function(_, opts)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local has_blink, blink = pcall(require, "blink.cmp")
      if has_blink then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      capabilities = vim.tbl_deep_extend("force", capabilities, {
        textDocument = {
          diagnostic = {
            dynamicRegistration = true,
          },
        },
      })

      local cmd
      if vim.fn.executable("roslyn-language-server") == 1 then
        cmd = {
          "roslyn-language-server",
          "--logLevel",
          "Information",
          "--extensionLogDirectory",
          vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs"),
          "--stdio",
        }
      elseif vim.fn.executable("Microsoft.CodeAnalysis.LanguageServer") == 1 then
        cmd = {
          "Microsoft.CodeAnalysis.LanguageServer",
          "--logLevel",
          "Information",
          "--extensionLogDirectory",
          vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs"),
          "--stdio",
        }
      end

      local roslyn_config = {
        capabilities = capabilities,
        settings = {
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "openFiles",
            dotnet_compiler_diagnostics_scope = "openFiles",
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
          },
          ["csharp|completion"] = {
            dotnet_provide_regex_completions = true,
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true,
          },
          ["csharp|symbol_search"] = {
            dotnet_search_reference_assemblies = true,
          },
        },
      }

      if cmd then
        roslyn_config.cmd = cmd
      end

      vim.lsp.config("roslyn", roslyn_config)
      require("roslyn").setup(opts)
    end,
  },
}
