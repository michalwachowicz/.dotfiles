return {
  "stevearc/conform.nvim",
  opts = {
    format_on_save = function(bufnr)
      if vim.bo[bufnr].filetype == "go" then
        return { lsp_format = "fallback", timeout_ms = 1000 }
      end
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      terraform = { "terraform_fmt" },
      tf = { "terraform_fmt" },
      go = { "goimports", "gofumpt" },
    },
  },
}
