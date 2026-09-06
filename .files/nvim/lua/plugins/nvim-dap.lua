return {
    "mfussenegger/nvim-dap",
    dependencies = "igorlfs/nvim-dap-view",
    config = function()
        local dap = require("dap")
        dap.adapters.python = {
            type = "executable",
            command = "path/to/virtualenvs/debugpy/bin/python",
            args = { "-m", "debugpy.adapter" },
        }

        dap.configurations.scala = {
            {
                type = "scala",
                request = "launch",
                name = "RunOrTest",
                metals = {
                    runType = "runOrTestFile",
                    --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
                },
            },
            {
                type = "scala",
                request = "launch",
                name = "Test Target",
                metals = {
                    runType = "testTarget",
                },
            },
        }
        dap.configurations.python = {
            {
                -- The first three options are required by nvim-dap
                type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
                request = "launch",
                name = "Launch file",

                -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

                program = "${file}", -- This configuration will launch the current file if used.
                pythonPath = function()
                    -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
                    -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
                    -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
                    local cwd = vim.fn.getcwd()
                    if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                        return cwd .. "/venv/bin/python"
                    elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                        return cwd .. "/.venv/bin/python"
                    else
                        return "/usr/bin/python"
                    end
                end,
            },
        }
    end,
    opts = function()
        local dap, dap_view = require("dap"), require("dap-view")
        dap.listeners.after.event_initialized.dapview_config = function()
            dap_view.open()
        end
        dap.listeners.before.event_terminated.dapview_config = function(session)
            vim.notify(tostring(session))
        end
        dap.listeners.before.event_exited.dapview_config = function()
            vim.notify("DAP Session closed")
        end
    end,
}
