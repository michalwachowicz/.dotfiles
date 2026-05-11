return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
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
        "terraform",
        "hcl",
      },
      highlight = { enable = true },
    })
  end,
}

