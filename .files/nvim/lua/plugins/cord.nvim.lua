-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
    "vyfor/cord.nvim",
    build = ":Cord update",
    event = "VeryLazy",
    opts = {
        usercmds = true,      -- Enable user commands
        log_level = "error",  -- One of 'trace', 'debug', 'info', 'warn', 'error', 'off'
        timer = {
            interval = 5000,  -- Interval between presence updates in milliseconds (min 500)
            reset_on_idle = true, -- Reset start timestamp on idle
            reset_on_change = true, -- Reset start timestamp on presence change
        },
        editor = {
            image = nil,                                          -- Image ID or URL in case a custom client id is provided
            client = "neovim",                                    -- vim, neovim, lunarvim, nvchad, astronvim or your application's client id
            tooltip = "Because Typing Should Feel Like Casting Spells", -- Text to display when hovering over the editor's image
        },
        display = {
            show_time = true, -- Display start timestamp
            show_repository = true, -- Display 'View repository' button linked to repository url, if any
            swap_icons = true, -- If enabled, editor is displayed on the main image
        },
        lsp = {
            show_problem_count = true, -- Display number of diagnostics problems
            severity = 1,        -- 1 = Error, 2 = Warning, 3 = Info, 4 = Hint
            scope = "workspace", -- buffer or workspace
        },
        idle = {
            enable = true, -- Enable idle status
            show_status = true, -- Display idle status, disable to hide the rich presence on idle
            timeout = 300000, -- Timeout in milliseconds after which the idle status is set, 0 to display immediately
            disable_on_focus = false, -- Do not display idle status when neovim is focused
            text = "Idle", -- Text to display when idle
            tooltip = "💤", -- Text to display when hovering over the idle image
        },
        assets = nil, -- Custom file icons, see the wiki*
    },
}
