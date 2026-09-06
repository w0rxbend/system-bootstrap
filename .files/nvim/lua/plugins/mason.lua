-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Mason plugins

---@type LazySpec
return {
    -- use mason-tool-installer for automatically installing Mason packages
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        -- overrides `require("mason-tool-installer").setup(...)`
        opts = {
            -- Make sure to use the names found in `:Mason`
            ensure_installed = {
                -- install language servers
                "lua-language-server",

                -- install formatters, linters and LSP servers
                "stylua",
                "ansible-language-server",
                "ansible-lint",
                "arduino-language-server",
                "cmake-language-server",
                "cmakelang",
                "cmakelint",

                "shellcheck",
                "editorconfig-checker",
                "marksman",
                "shfmt",
                "ruff",
                "gopls",
                "serve-d",
                "zls",
                "jdtls",
                "pyrefly",
                "black",
                "isort",
                "flake8",
                "rust-analyzer",
                "json-lsp",
                "jsonlint",
                "bash-language-server",
                "yaml-language-server",
                "yamllint",
                "taplo",
                "docker-language-server",
                "dockerfile-language-server",
                "docker-compose-language-service",
                "terraform-ls",
                "terraform",
                "sqls",
                "nimlangserver",
                "tinymist",
                "texlab",
                -- install debuggers
                "debugpy",

                -- install any other package
                "tree-sitter-cli",
            },
        },
    },
}
