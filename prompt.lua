---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Julien Danjou
-- @release v3.5.1-sammyshp
---------------------------------------------------------------------------

local setmetatable = setmetatable

local completion = require("awful.completion")
local util = require("awful.util")
local prompt = require("awful.prompt")
local widget_base = require("wibox.widget.base")
local textbox = require("wibox.widget.textbox")
local background = require("wibox.widget.background")
local type = type

-- widgets.prompt
local widgetprompt = { mt = {} }

--- Run method for promptbox.
-- @param promptbox The promptbox to run.
local function run(promptbox)
    return prompt.run(promptbox.widget.args,
                      promptbox.widget.widget,
                      function (...)
                          local result = util.spawn(...)
                          if type(result) == "string" then
                              promptbox.widget.widget:set_text(result)
                          end
                      end,
                      completion.shell,
                      util.getdir("cache") .. "/history")
end

--- Create a prompt widget which will launch a command.
-- @param args Arguments table. "prompt" is the prompt to use.
-- @return A launcher widget.
function widgetprompt.new(args)
    local args = args or {}
    args.prompt = args.prompt or "Run: "
    local widget = textbox()
    local promptbox = widget_base.make_widget(widget)

    promptbox.widget = widget
    promptbox.widget:set_ellipsize("start")
    promptbox.args = args

    local container = background()
    container:set_widget(promptbox)
    container:set_bg(args.bg or nil)
    container.run = run

    return container
end

function widgetprompt.mt:__call(...)
    return widgetprompt.new(...)
end

return setmetatable(widgetprompt, widgetprompt.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
