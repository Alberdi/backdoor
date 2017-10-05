
local DB    = require 'database'
local RES   = require 'resources'
local FONT = require 'view.helpers.font'
local DEFS  = require 'domain.definitions'

--PackView Class--

local PackView = Class{
  __includes = { ELEMENT }
}

--CONSTS--
local _f_name = "Text" --Font name
local _f_size = 24 --Font size

--CLASS FUNCTIONS--

function PackView:init(actor)

  ELEMENT.init(self)

  self.focus_index = 1  -- What card is focused
  self.target = 0       -- Buffer index (zero is "consume")
  self.actor = actor
  self.pack = {}

  for _,card_specname in actor:iteratePack() do
    table.insert(self.pack, { specname = card_specname })
  end

end

function PackView:removeCurrent()
  table.remove(self.pack, self.focus_index)
  self.focus_index = math.min(self.focus_index, #self.pack)
end

function PackView:isEmpty()
  return #self.pack == 0
end

function PackView:getFocus()
  return self.focus_index
end

function PackView:moveFocus(dir)
  if dir == "left" then
    self.focus_index = math.max(1, self.focus_index - 1)
  elseif dir == "right" then
    self.focus_index = math.min(#self.pack, self.focus_index + 1)
  end
end

function PackView:getTarget()
  if self.target == 0 then
    return 'consume', 0
  else
    return 'get', self.target
  end
end

function PackView:changeTarget(dir)
  local N = DEFS.ACTOR_BUFFER_NUM+1
  if dir == 'up' then
    self.target = (self.target - 1) % N
  elseif dir == 'down' then
    self.target = (self.target + 1) % N
  else
    error(("Unknown dir %s"):format(dir))
  end
end

function PackView:draw()
  local x, y = 800,400
  local g = love.graphics
  local card_data = self.pack[self.focus_index]
  if card_data then
    local card = DB.loadSpec('card', card_data.specname)
    local view = ("%s [%d/%d]"):format(card.name, self.focus_index,
                                       #self.pack)
    FONT.set(_f_name,_f_size)
    g.print(view, x, y)
    local t, n = self:getTarget()
    g.print(("%s %d"):format(t, n), x, y + FONT.get(_f_name,_f_size):getHeight())
  end
end

return PackView
