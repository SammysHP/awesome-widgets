---------------------------------------------------------------------------
-- @author Sven Karsten Greiner <sven@sammyshp.de>
-- @copyright 2013 Sven Karsten Greiner
-- @release v3.5.1-sammyshp
---------------------------------------------------------------------------

local setmetatable = setmetatable

local awful = require("awful")
local timer = require("gears.timer")
local textbox = require("wibox.widget.textbox")
local string = string

--- Volume widget.
-- widgets.volume
local volume = { mt = {} }

function update_volume_text(w, c)
    awful.spawn.easy_async("amixer -M sget " .. c, function (stdout, stderr, reason, exit_code)
        local status = stdout
        local volume = string.match(status, "(%d?%d?%d)%%")

        status = string.match(status, "%[(o[^%]]*)%]")

        if not status then
            volume = "♫?"
        elseif string.find(status, "on", 1, true) then
            volume = "♫" .. volume
        else
            volume = "♫M"
        end

        if w ~= nil then
            w.text = volume
        end
    end)
end

function raise_volume(w, c)
    awful.spawn("amixer -q set " .. c .. " 1+ unmute", false)
    update_volume_text(w, c)
end

function lower_volume(w, c)
    awful.spawn("amixer -q set " .. c .. " 1- unmute", false)
    update_volume_text(w, c)
end

function toggle_mute(w, c)
    awful.spawn("amixer -q set " .. c .. " toggle", false)
    update_volume_text(w, c)
end

function volume.new(args)
    local args = args or {}
    local timeout = args.timeout or 31
    local terminal = args.terminal or "x-terminal-emulator"
    local channel = args.channel or "Master"

    local w = textbox()

    local ww = {
        widget = w,
        raise = function () raise_volume(w, channel) end,
        lower = function () lower_volume(w, channel) end,
        mute  = function () toggle_mute(w, channel) end
    }

    w:buttons(awful.util.table.join(
        awful.button({ }, 1, function()
                awful.spawn(terminal .. " -e alsamixer", false)
            end),
        awful.button({ }, 3, function() ww.mute() end),
        awful.button({ }, 4, function() ww.raise() end),
        awful.button({ }, 5, function() ww.lower() end)
    ))

    local t = timer({ timeout = timeout })
    t:connect_signal("timeout", function () update_volume_text(w, channel) end)
    t:start()
    t:emit_signal("timeout")

    return ww
end

function volume.mt:__call(...)
    return volume.new(...)
end

return setmetatable(volume, volume.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
