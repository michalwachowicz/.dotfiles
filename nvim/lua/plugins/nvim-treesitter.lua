return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    require("nvim-treesitter").install({
      "typescript",
      "tsx",
      "javascript",
      "html",
      "css",
      "json",
      "c_sharp",
      "lua",
      "vim",
      "vimdoc",
      "bash",
    }):wait(300000)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "typescript",
        "typescriptreact",
        "javascript",
        "javascriptreact",
        "cs",
        "html",
        "css",
        "json",
        "lua",
        "vim",
        "sh",
      },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}

