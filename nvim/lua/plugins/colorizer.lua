return {
  "NvChad/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    filetypes = { "*" },
    user_default_options = {
      css = true,
      css_fn = true,
      mode = "background",
      names = false,
      tailwind = true,
      tailwind_opts = {
        update_names = true,
      },
    },
  },
  config = function(_, opts)
    require("colorizer").setup(opts)
  end,
}
