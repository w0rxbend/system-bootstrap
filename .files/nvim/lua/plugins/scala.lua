return {
    {
        "scalameta/nvim-metals",
        opts = function(_, opts)
            opts.handlers = opts.handlers or {}
            opts.handlers["window/showMessage"] = function(_, result, _)
                local lvl = ({ "ERROR", "WARN", "INFO", "DEBUG" })[result.type]
                vim.notify(result.message, vim.log.levels[lvl] or vim.log.levels.INFO)
            end
            return opts
        end,
    },
}
