---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Julien Danjou
-- @release v3.5.2-sammyshp
---------------------------------------------------------------------------

local setmetatable = setmetatable
local os = os
local textbox = require("wibox.widget.textbox")
local capi = { timer = timer }
local naughty = require("naughty")

--- Text clock widget.
-- widget.textclock
local textclock = { mt = {} }

--- Create a textclock widget. It draws the time it is in a textbox.
-- @param format The time format. Default is " %a %b %d, %H:%M ".
-- @param timeout How often update the time. Default is 60.
-- @param locale The locale of the time format.
-- @return A textbox widget.
function textclock.new(format, timeout, locale)
    local format = format or " %a %b %d, %H:%M "
    local timeout = timeout or 60

    if locale then
        os.setlocale(locale, "time")
    end

    local w = textbox()
    local timer = capi.timer { timeout = timeout }
    timer:connect_signal("timeout", function() w:set_markup(os.date(format)) end)
    timer:start()
    timer:emit_signal("timeout")
    return w
end

function textclock.mt:__call(...)
    return textclock.new(...)
end

return setmetatable(textclock, textclock.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
