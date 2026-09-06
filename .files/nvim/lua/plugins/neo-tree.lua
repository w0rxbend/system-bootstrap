return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        opts = {
            filesystem = {
                filtered_items = {
                    visible = true,
                    show_hidden_count = true,
                    hide_dotfiles = false,
                    hide_gitignored = true,
                    hide_by_name = {
                        ".git",
                        "target",
                        ".bsp",
                        ".clangd",
                        ".vscode",
                        ".idea",
                        ".cache",
                        ".venv",
                        ".pytest_cache",
                        "__pycache__",
                        ".",
                    },
                    never_show = {
                        ".git",
                    },
                },
            },
        },
    },
}
