-- Plugin setup. Plugins are listed in package.toml; `ya pkg install` fetches them.

require("full-border"):setup({ type = ui.Border.ROUNDED })
require("git"):setup({ order = 1500 })
