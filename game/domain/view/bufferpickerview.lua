
local DIR = require 'domain.definitions.dir'

--BufferPickerView Class--

local BufferPickerView = Class {
  __includes = { ELEMENT }
}

--CLASS FUNCTIONS--

function BufferPickerView:init(actor)

  ELEMENT.init(self)

  self.actor = actor
  self.select = 1

end

function BufferPickerView:draw()
  local X,Y = O_WIN_W/2, O_WIN_H/2
  local g = love.graphics
  local w,h = 128,128
  local size = self.actor:getBufferSize(self.select)
  g.setColor(100, 100, 150)
  g.rectangle('fill', X-w/2, Y-h/2, w, h)
  g.setColor(255, 255, 200)
  g.print(("%d (%2d)"):format(self.select, size), X, Y)
end

function BufferPickerView:moveSelection(dir)
  local n = #self.actor.buffers
  if dir == 'left' then
    self.select = (self.select - 2)%n + 1
  elseif dir == 'right' then
    self.select = self.select%n + 1
  else
    error(("Invalid direction %s!"):format(dir))
  end
end

function BufferPickerView:getSelection()
  return self.select
end

return BufferPickerView

