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

--- Load average widget.
-- widgets.loadavg
local loadavg = { mt = {} }

function get_current_load()
    local lf = io.open("/proc/loadavg")
    local l = lf:read()
    lf:close()
    return string.match(l, "(%d.%d+).*")
end

function loadavg.new(interval)
    local w = textbox()
    local t = timer({ timeout = interval })
    t:connect_signal("timeout", function () w:set_text(get_current_load()) end)
    t:start()
    t:emit_signal("timeout")
    return w
end

function loadavg.mt:__call(...)
    return loadavg.new(...)
end

return setmetatable(loadavg, loadavg.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
