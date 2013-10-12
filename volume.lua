---------------------------------------------------------------------------
-- @author Sven Karsten Greiner <sven@sammyshp.de>
-- @copyright 2013 Sven Karsten Greiner
-- @release v3.5.1-sammyshp
---------------------------------------------------------------------------

local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local awful = require("awful")
local io = io
local string = string
local timer = timer

--- Volume widget.
-- widgets.volume
local volume = { mt = {} }

function get_volume_text()
    local fd = io.popen("amixer sget Master")
    local status = fd:read("*all")
    fd:close()
    
    local volume = string.match(status, "(%d?%d?%d)%%")

    status = string.match(status, "%[(o[^%]]*)%]")

    if string.find(status, "on", 1, true) then
        volume = "♫" .. volume
    else
        volume = "♫M"
    end
    return volume
end

function raise_volume(w)
    awful.util.spawn("amixer -q set Master 1+ unmute")
    if w ~= nil then
        w:set_text(get_volume_text())
    end
end

function lower_volume(w)
    awful.util.spawn("amixer -q set Master 1- unmute")
    if w ~= nil then
        w:set_text(get_volume_text())
    end
end

function toggle_mute(w)
    awful.util.spawn("amixer -q set Master toggle")
    if w ~= nil then
        w:set_text(get_volume_text())
    end
end

function volume.new(interval)
    local w = textbox()

    w:buttons(awful.util.table.join(
        awful.button({ }, 1, function()
            awful.util.spawn("x-terminal-emulator -e alsamixer")
        end)
    ))

    local t = timer({ timeout = 30 })
    t:connect_signal("timeout", function () w:set_text(get_volume_text()) end)
    t:start()
    t:emit_signal("timeout")

    return {
        widget = w,
        raise = function () raise_volume(w) end,
        lower = function () lower_volume(w) end,
        mute = function () toggle_mute(w) end
    }
end

function volume.mt:__call(...)
    return volume.new(...)
end

return setmetatable(volume, volume.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
