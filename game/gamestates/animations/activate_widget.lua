
local Util          = require "steaming.util"
local TweenValue    = require 'view.helpers.tweenvalue'
local VIEWDEFS      = require 'view.definitions'
local Dissolve      = require 'view.dissolvecard'
local vec2          = require 'cpml' .vec2

local ANIM = require 'common.activity' ()

-- luacheck: no self, globals MAIN_TIMER

local _waitAndAnnounce
local _slideUp
local _slideDown

function ANIM:script(route, view, report)
  local action_hud = view.action_hud
  local delay = TweenValue(0)
  if report.body:getActor() == route:getControlledActor() then
    local backbuffer = view.backbuffer
    _waitAndAnnounce(report.widget, self.wait)
    --local widgetview = action_hud:getWidgetCard(widget)
  end
  delay:kill()
  return self
end

function _waitAndAnnounce(widget, wait)
  local ann = Util.findId('announcement')
  ann:lock()
  local deferred = ann:interrupt()
  if deferred then wait(deferred) end
  ann:announce(widget:getName())
  ann:unlock()
end

-- function _slideUp(cardview, backbuffer, task)
--   local delay = TweenValue(0)
--   local target_pos = backbuffer:getTopCardPosition()
--                    - vec2(0,VIEWDEFS.CARD_H) * 2
--   cardview:addTimer("slide_right", MAIN_TIMER, "tween", .5, cardview,
--                     { position = target_pos }, 'out-cubic',
--                     function () task.resume() end)
--   task.wait()
--   task.wait(delay:set(0.2))
--   delay:kill()
-- end
--
-- function _slideDown(cardview, backbuffer)
--     cardview:addTimer("slide_down", MAIN_TIMER, "tween", .5, cardview,
--                       { position = backbuffer:getTopCardPosition() },
--                       'out-cubic')
--     cardview:addTimer("wait", MAIN_TIMER, "after", .3,
--                       function ()
--                         cardview:addTimer("fadeout", MAIN_TIMER, "tween", .3,
--                                           cardview, {alpha = 0}, 'out-cubic',
--                                           function() cardview:kill() end)
--                       end)
-- end
--
-- function _dissolve(cardview)
--   local delay = TweenValue(0)
--   delay:set(1.6):andThen(function () cardview:kill() end)
--   Dissolve(cardview, 1.5)
--   delay:kill()
-- end

return ANIM
