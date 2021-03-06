
-- luacheck: globals MAIN_TIMER

local DB        = require 'database'
local RES       = require 'resources'
local VIEWDEFS  = require 'view.definitions'
local Deferred  = require 'common.deferred'

local vec2      = require 'cpml'.vec2
local Class     = require "steaming.extra_libs.hump.class"
local ELEMENT   = require "steaming.classes.primitives.element"

local BodyView = Class {
  __includes = { ELEMENT }
}

local BLINK = { true, false, true, false, true, false }
local Outline = require 'view.helpers.outline'()
local OUTLINE_DECOR = function(self, x, y)
  local g = love.graphics -- luacheck: globals love
  Outline:color(1, 1, 1)
  local quad = self:updateAndGetCurrentQuadOfSprite(self)
  local tex = self.texture
  local ox, oy = self:getOffset()
  Outline:predraw(3, nil, quad)
  g.draw(tex, quad, x, y, 0, self.sx, self.sy, ox, oy)
  g.setShader()
end

function BodyView:init(body)
  ELEMENT.init(self)
  if body.getBody then
    body = body:getBody()
  end
  local idle_appearance = DB.loadSpec('appearance', body:getAppearance()).idle
  local i, j = body:getPos()
  self.sprite = RES.loadSprite(idle_appearance)
  self.body = body
  self.position = BodyView.tileToScreen(i, j)
  self.offset = vec2()
end

function BodyView.tileToScreen(i, j)
  return vec2((j - 1) * VIEWDEFS.TILE_W, (i - 1) * VIEWDEFS.TILE_H)
end

function BodyView.tileDiffToScreen(di, dj)
  return vec2(dj * VIEWDEFS.TILE_W, di * VIEWDEFS.TILE_H)
end

function BodyView:getPosition()
  return self.position:clone()
end

function BodyView:getScreenPosition()
  local route = self.body:getSector():getRoute()
  local controlled_actor = route.getPlayerActor()
  local camera_pos = BodyView.tileToScreen(controlled_actor:getBody():getPos())
  return self.position - camera_pos
end

function BodyView:setPosition(i, j)
  self.position = BodyView.tileToScreen(i, j)
end

function BodyView:setOffset(offset)
  self.offset = offset
end

function BodyView:moveTo(i, j, t, curve)
  curve = curve or 'in-out-cubic'
  local deferred = Deferred:new{}
  local target = BodyView.tileToScreen(i, j)
  assert(not self:getTimer("move_to", MAIN_TIMER))
  self:addTimer("move_to", MAIN_TIMER, "tween", t, self, { position = target },
                curve, function () deferred:trigger()
                                   self:removeTimer('move_to', MAIN_TIMER) end)
  return deferred
end

function BodyView:offsetTo(target, t, tag)
  local deferred = Deferred:new{}
  assert(not self:getTimer(tag, MAIN_TIMER))
  self:addTimer(
    tag, MAIN_TIMER, "tween", t, self, { offset = target },
    'in-out-cubic',
    function ()
      deferred:trigger()
      self:removeTimer(tag, MAIN_TIMER)
    end
  )
  return deferred
end

function BodyView:jump(t)
  local _, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  local target = vec2(0, -h)
  return self:offsetTo(target, t, 'jump')
end

function BodyView:fall(t)
  local target = vec2(0, 0)
  return self:offsetTo(target, t, 'fall')
end

function BodyView:hit(dir)
  local offset = dir * 24
  offset = { x = offset.x, y = offset.y }
  local deferred = Deferred:new{}
  self:addTimer(
    nil, MAIN_TIMER, 'tween', 0.1, self.offset, offset, 'in-cubic',
    function() -- after tween
      local count = 1
      self:addTimer(
        nil, MAIN_TIMER, 'every', 0.075,
        function()
          self.invisible = BLINK[count]
          count = count + 1
        end,
        #BLINK
      )
      self:addTimer(nil, MAIN_TIMER, 'tween', 0.4, self.offset,
                    { x = 0, y = 0}, 'out-cubic',
                    function() deferred:trigger() end)
    end
  )
  return deferred
end

function BodyView:act()
  self.offset.x = - VIEWDEFS.TILE_W / 4.0
  local deferred = Deferred:new{}
  self:addTimer(
    nil, MAIN_TIMER, 'tween', 0.1, self.offset, { x = VIEWDEFS.TILE_W / 4.0 },
    'in-linear',
    function() -- after tween
      self.offset.x = 0
      deferred:trigger()
    end
  )
  return deferred
end

function BodyView:drawAtRow(row, use_outline)
  if not self.invisible then
    local x = self.position.x + self.offset.x
    local y = self.position.y + self.offset.y - row * VIEWDEFS.TILE_H
    if use_outline then
      self.sprite:setDecorator(OUTLINE_DECOR)
    else
      self.sprite:setDecorator()
    end
    self.sprite:draw(x, y)
  end
end

function BodyView:getSprite()
  return self.sprite
end

return BodyView
