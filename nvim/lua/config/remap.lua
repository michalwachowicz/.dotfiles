local telescope = require("telescope.builtin")
local telescope_actions = require("telescope.actions")
local harpoon_utils = require("utils/harpoon-utils")
local harpoon = require("harpoon")

-- Basic --
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", "\"_dP")
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- LSP --
local function has_omnisharp_attached()
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		if client.name == "omnisharp" or client.name == "omnisharp_mono" then
			return true
		end
	end

	return false
end

vim.keymap.set("n", "gd", function()
	if has_omnisharp_attached() then
		local ok, omnisharp_extended = pcall(require, "omnisharp_extended")
		if ok then
			omnisharp_extended.telescope_lsp_definition({ jump_type = "never" })
			return
		end
	end

	telescope.lsp_definitions()
end)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end)

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)

-- Telescope --
vim.keymap.set("n", "<leader>pf", telescope.find_files, {})
vim.keymap.set("n", "<C-p>", telescope.git_files, {})
vim.keymap.set("n", "<leader>ps", function()
	telescope.grep_string({ search = vim.fn.input("Grep > ") })
end)

vim.api.nvim_create_autocmd("FileType", {
	pattern = "TelescopePrompt",
	callback = function()
		local opts = { buffer = true, silent = true }
		vim.keymap.set({ "i", "n" }, "<C-c>", function()
			telescope_actions.close(vim.api.nvim_get_current_buf())
		end, opts)
	end,
})

-- UndoTree --
vim.g.undotree_SetFocusWhenToggle = 1
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Diffview --
vim.keymap.set("n", "<leader>go", "<cmd>DiffviewOpen<cr>")
vim.keymap.set("n", "<leader>gc", function()
  vim.cmd("DiffviewClose")
  vim.cmd("windo diffoff")
  pcall(vim.cmd, "only")
end)
vim.keymap.set("n", "<leader>gf", "<cmd>DiffviewFileHistory %<CR>")
vim.keymap.set("n", "<leader>gF", "<cmd>DiffviewFileHistory<CR>")

-- Harpoon --
harpoon:setup()

vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end)
vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
vim.keymap.set("n", "<leader>hp", harpoon_utils.prev_wrap)
vim.keymap.set("n", "<leader>hn", harpoon_utils.next_wrap)

-- Tmux --
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>");
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>");
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>");
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>");
