return {
	"folke/todo-comments.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local todo_comments = require("todo-comments")

		todo_comments.setup({
			keywords = {
				TODO = { icon = " ", color = "info" },
				HACK = { icon = " ", color = "warning" },
				BUG = { icon = " ", color = "error" },
				FIX = { icon = " ", color = "error" },
				-- Agrega más palabras clave según sea necesario
			},
			highlight = {
				before = "",
				keyword = "bg",
				after = "fg",
				pattern = [[.*<(KEYWORDS)\s*:]],
				-- Cambia el patrón si tus comentarios tienen un formato diferente
			},
			search = {
				command = "rg",
				args = { "--ignore-case", "--hidden", "--glob", "!**/.git/*" },
				-- Cambia los argumentos de búsqueda si es necesario
			},
		})

		-- Set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "]t", function()
			todo_comments.jump_next()
		end, { desc = "Next todo comment" })

		keymap.set("n", "[t", function()
			todo_comments.jump_prev()
		end, { desc = "Previous todo comment" })
	end,
}
