-- Customize Treesitter
-- --------------------
-- Treesitter customizations are handled with AstroCore
-- as nvim-treesitter simply provides a download utility for parsers

---@type LazySpec
return {
	"AstroNvim/astrocore",
	---@type AstroCoreOpts
	opts = {
		treesitter = {
			highlight = true, -- enable/disable treesitter based highlighting
			indent = true, -- enable/disable treesitter based indentation
			auto_install = true, -- enable/disable automatic installation of detected languages
			ensure_installed = {
				"lua",
				"vim",
				"scala",
				"java",
				"javascript",
				"typescript",
				"python",
				"bash",
				"c",
				"cpp",
				"rust",
				"markdown",
				"yaml",
				"toml",
				"json",
				"html",
				"css",
				"scss",
				"ruby",
				"make",
				"sql",
				"go",
				"sh",
				"dockerfile",
				"julia",
				"scala",
				"erlang",
				"elixir",
				"clojure",
				-- add more arguments for adding more treesitter parsers
			},
		},
	},
}
