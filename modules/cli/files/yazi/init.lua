-- Plugin setup. Plugins are listed in package.toml; `ya pkg install` fetches them.
-- Plugins bound only in keymap.toml (smart-enter, smart-filter, chmod, ...) need no setup.

require("full-border"):setup({ type = ui.Border.ROUNDED })
require("git"):setup({ order = 1500 })

-- Inside a Neovim terminal the preview is cramped: start hidden, <C-t> shows it.
if os.getenv("NVIM") then
    require("toggle-pane"):entry("min-preview")
end

-- Header: user@host before the path (yazi docs, tips).
Header:children_add(function()
    if ya.target_family() ~= "unix" then
        return ""
    end
    return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("#89b4fa")
end, 500, Header.LEFT)

-- Status bar: owner:group of the hovered file (yazi docs, tips; `cha` is the v26.9.1 field).
Status:children_add(function()
    local h = cx.active.current.hovered
    if not h or ya.target_family() ~= "unix" then
        return ""
    end

    return ui.Line({
        ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("#cba6f7"),
        ":",
        ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("#cba6f7"),
        " ",
    })
end, 500, Status.RIGHT)
