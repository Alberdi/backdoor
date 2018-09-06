
local CARD  = require 'view.helpers.card'
local COLORS = require 'domain.definitions.colors'
local FONT = require 'view.helpers.font'
local Color = require 'common.color'
local vec2  = require 'cpml' .vec2

local _W
local _MW = 16
local _MH = 8

local CardInfo = Class{
  __includes = { ELEMENT }
}

function CardInfo:init(route)

  ELEMENT.init(self)

  self.route = route
  self.card = nil
  self.position = vec2()
  self.hide_desc = true
  self.title_font = FONT.get("TextBold", 16)
  self.text_font = FONT.get("Text", 16)

  _W = love.graphics.getDimensions()/4

end

function CardInfo:setCard(card)
  self.card = card
end

function CardInfo:setPosition(pos)
  self.position = pos
end

function CardInfo:show()
  self.invisible = false
end

function CardInfo:hide()
  self.invisible = true
end

function CardInfo:isVisible()
  return not self.invisible
end

function CardInfo:update(dt)

end

function CardInfo:draw()
  local alpha = 1
  if self.card == 'draw' then
    self.card = require 'view.helpers.newhand_card'
  end
  local g = love.graphics
  local cr, cg, cb = unpack(COLORS.NEUTRAL)
  local player_actor = self.route.getPlayerActor()

  local desc = self.card:getEffect(player_actor)
  if not self.hide_desc then
    desc = desc .. "\n\n---"
    desc = desc .. '\n\n' .. (self.card:getDescription() or "[No description]")
  end
  desc = desc:gsub("([^\n])[\n]([^\n])", "%1 %2")
  desc = desc:gsub("\n\n", "\n")

  self.text_font:setLineHeight(1)
  local width, lines = self.text_font:getWrap(desc, _W)
  local height = self.title_font:getHeight()
               + #lines * self.text_font:getHeight()
                        * self.text_font:getLineHeight()

  g.push()

  g.translate(self.position:unpack())
  
  g.setColor(COLORS.DARKER)
  g.rectangle('fill', 0, 0, _W + 2*_MW, height + 2*_MH)
  g.setColor(COLORS.NEUTRAL)
  g.setLineWidth(2)
  g.rectangle('line', 0, 0, _W + 2*_MW, height + 2*_MH)

  g.translate(_MW, _MH)

  g.setColor(cr, cg, cb, alpha)

  self.title_font:setLineHeight(1.5)
  self.title_font.set()
  g.printf(self.card:getName(), 0, 0, _W)

  g.translate(0, self.title_font:getHeight())

  self.text_font.set()
  g.printf(desc, 0, 0, _W)

  g.pop()
end

return CardInfo

