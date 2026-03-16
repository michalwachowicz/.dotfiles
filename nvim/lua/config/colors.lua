vim.cmd.colorscheme("tokyonight-night")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

local function set_neotree_open_file_highlight()
  vim.api.nvim_set_hl(0, "NeoTreeFileNameOpened", {
    fg = "#9ece6a",
    bold = true,
    underline = true,
  })
end

set_neotree_open_file_highlight()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_neotree_open_file_highlight,
})
