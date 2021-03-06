
local FONT        = require 'view.helpers.font'
local VIEW_COLORS = require 'view.definitions.colors'
local DB          = require 'database'

local Class     = require "steaming.extra_libs.hump.class"
local ELEMENT   = require "steaming.classes.primitives.element"

local InfoPanel = Class{
  __includes = { ELEMENT }
}

local _WIDTH = 240
local _HEADER_HEIGHT = 48
local _HEIGHT = 440
local _CORNER = 24
local _HPAD = 16
local _VPAD = 8
local _ALPHA_SPEED = 4

local _BODY_SHAPE = {
  0, _HEADER_HEIGHT,
  _WIDTH, _HEADER_HEIGHT,
  _WIDTH, _HEIGHT - _CORNER,
  _WIDTH - _CORNER, _HEIGHT,
  0, _HEIGHT,
}

local _HEADER_SHAPE = {
  _CORNER, 0,
  _WIDTH, 0,
  _WIDTH, _HEADER_HEIGHT,
  0, _HEADER_HEIGHT,
  0, _CORNER,
}

function InfoPanel:init(position, handview)

  ELEMENT.init(self)

  self.handview = handview
  self.position = position:clone()
  self.title = "TITLE"
  self.title_font = FONT.get('Title', 20)
  self.text_font = FONT.get('Text', 18)
  self.text = "> This is a test"
  self.modulate = VIEW_COLORS.IDENTITY:clone()
  self.modulate[4] = 0.0
  self.target_alpha = 0.0

  self.locked = nil

end

function InfoPanel:setText(title, text)
  text = text:gsub("([^\n])[\n]([^\n])", "%1 %2")
  self.text = text
  self.title = title
end

function InfoPanel:setTextFrom(element)
  if element then
    if element:is('card') then
      local player = self.handview.route.getPlayerActor()
      local title = element:getName()
      local text = element:getEffect(player)
      self:setText(title, text)
    elseif element:is('body') then
      local title = element:getName()
      local text = ""
      text = text .. "HP " .. element:getHP() .. "/" .. element:getMaxHP()
      text = text .. "\n\n"
      text = text .. "Threat: " .. element:getFaction()
      text = text .. "\n\n"
      text = text .. "Drops: "
      local comma = false
      for drop in pairs(element:getDropSet()) do
        if not comma then
          comma = true
        else
          text = text .. ", "
        end
        local name = DB.loadSpec('drop', drop)['name']
        text = text .. name
      end
      text = text .. "\n\n"
      text = text .. element:getDescription()
      self:setText(title, text)
    end
  end
end

function InfoPanel:lockElement(element)
  self.locked = element
end

function InfoPanel:hide()
  self.target_alpha = 0.0
end

function InfoPanel:show()
  self.target_alpha = 1.0
end

function InfoPanel:isVisible()
  return not self.invisible
end

function InfoPanel:update(dt)
  if self.target_alpha > self.modulate[4] then
    self.modulate[4] = math.min(self.target_alpha,
                                self.modulate[4] + _ALPHA_SPEED * dt)
  elseif self.target_alpha < self.modulate[4] then
    self.modulate[4] = math.max(self.target_alpha,
                                self.modulate[4] - _ALPHA_SPEED * dt)
  end
  self.invisible = self.modulate[4] <= 0
  if self.locked then
    self:setTextFrom(self.locked)
  end
end

function InfoPanel:draw()
  local g = love.graphics -- luacheck: globals love
  g.push()
  g.translate(self.position:unpack())
  -- HEADER
  g.setColor(VIEW_COLORS.BRIGHT * self.modulate)
  g.polygon('fill', _HEADER_SHAPE)
  g.setColor(VIEW_COLORS.DARK * self.modulate)
  self.title_font:set()
  g.printf(self.title:upper(), _HPAD, _VPAD, _WIDTH - 2*_HPAD, 'center')
  -- BODY
  g.setColor(VIEW_COLORS.DARK:withAlpha(0.8) * self.modulate)
  g.polygon('fill', _BODY_SHAPE)
  g.setColor(VIEW_COLORS.BRIGHT * self.modulate)
  g.setLineWidth(4)
  self.text_font:set()
  g.printf(self.text, _HPAD, _HEADER_HEIGHT + _HPAD, _WIDTH - 2*_HPAD, 'left')
  g.pop()
end

return InfoPanel

