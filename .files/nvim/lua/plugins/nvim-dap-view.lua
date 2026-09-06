return {
    "igorlfs/nvim-dap-view",
    -- let the plugin lazy load itself
    opts = {
        winbar = {
            show = true,
            controls = {
                enabled = true,
                position = "right",
                buttons = {
                    "play",
                    "step_into",
                    "step_over",
                    "step_out",
                    "step_back",
                    "run_last",
                    "terminate",
                    "disconnect",
                },
            },
        },
        auto_toggle = false,
    },
}
