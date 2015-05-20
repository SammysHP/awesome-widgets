---------------------------------------------------------------------------
-- @author Sven Karsten Greiner <sven@sammyshp.de>
-- @copyright 2013 Sven Karsten Greiner
-- @release v3.5.1-sammyshp
---------------------------------------------------------------------------

local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local io = io
local timer = timer
local string = string
local math = math

local BAT_UNKNOWN = 0
local BAT_DISCHARGING = 1
local BAT_CHARGING = 2
local BAT_AC = 3

--- Load average widget.
-- widgets.loadavg
local smapibat = { mt = {} }

function get_battery_status(adapter)
    local fper = io.open("/sys/devices/platform/smapi/" .. adapter .. "/remaining_percent")
    local percent = fper:read()
    fper:close()

    local fsta = io.open("/sys/devices/platform/smapi/" .. adapter .. "/state")
    local sta = fsta:read()
    fsta:close()

    local fpow = io.open("/sys/devices/platform/smapi/" .. adapter .. "/power_avg")
    local pow = fpow:read()
    fpow:close()

    local frem = io.open("/sys/devices/platform/smapi/" .. adapter .. "/remaining_running_time")
    local rem = frem:read()
    frem:close()

    local status
    if sta:match("discharging") then
        status = BAT_DISCHARGING
    elseif sta:match("charging") then
        status = BAT_CHARGING
    else
        status = BAT_AC
    end

    local indicator
    local watt = ""
    local remaining = ""

    if status == BAT_DISCHARGING then
        indicator = "↓"
        watt = string.format(" %.2f", pow / -1000) .. "W"
        remaining = string.format(" %dh%dm", math.floor(rem / 60), math.floor(rem % 60))
    elseif status == BAT_CHARGING then
        indicator = "↑"
    elseif status == BAT_AC then
        indicator = "AC"
        percent = ""
    else
        indicator = "?"
        percent = ""
    end

    return "⚡" .. percent .. indicator .. watt .. remaining
end

function smapibat.new(adapter, interval)
    local w = textbox()
    local t = timer({ timeout = interval })
    t:connect_signal("timeout", function () w:set_text(get_battery_status(adapter)) end)
    t:start()
    t:emit_signal("timeout")
    return w
end

function smapibat.mt:__call(...)
    return smapibat.new(...)
end

return setmetatable(smapibat, smapibat.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
