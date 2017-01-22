---------------------------------------------------------------------------
-- @author Sven Karsten Greiner <sven@sammyshp.de>
-- @copyright 2013 Sven Karsten Greiner
-- @release v3.5.1-sammyshp
---------------------------------------------------------------------------

local setmetatable = setmetatable
local os = os
local textbox = require("wibox.widget.textbox")
local awful = require("awful")

--- Taginfo widget.
-- widgets.taginfo
local taginfo = { mt = {} }

function refresh(w)
    return function (tag)
        if not tag then return end
        w:set_text(tag.master_count .. "/" .. tag.column_count .. " ")
    end
end

function taginfo.new(screen)
    local w = textbox()
    local callback = refresh(w)

    callback(screen.selected_tag)

    awful.tag.attached_connect_signal(screen, "property::master_count", callback)
    awful.tag.attached_connect_signal(screen, "property::column_count", callback)
    awful.tag.attached_connect_signal(screen, "property::selected", callback)

    return w
end

function taginfo.mt:__call(...)
    return taginfo.new(...)
end

return setmetatable(taginfo, taginfo.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
