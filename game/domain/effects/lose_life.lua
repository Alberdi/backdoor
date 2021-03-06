
local math = require 'common.math'

local FX = {}

FX.schema = {
  { id = 'percentage', name = "HP Percentage", type = 'integer',
    range = {1, 90}
  },
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'stay_alive', name = "Stay Alive?", type = 'boolean' },
}

-- can be for self-damaging attacks, as well as effects like poison

function FX.preview(actor, fieldvalues)
  local str = ("lose %s%% hit points"):format(fieldvalues['percentage'])
  if fieldvalues['stay_alive'] then
    str = str .. " (non-lethal)"
  end
  return  str
end

function FX.process (actor, fieldvalues)
  local body = actor:getBody()
  local current_hp = body:getHP()
  local max_hp = body:getMaxHP()
  local amount = math.round(max_hp*fieldvalues.percentage/100)
  if fieldvalues.stay_alive then
    amount = math.min(current_hp - 1, amount)
  end
  local dmg = body:loseLifeFrom(amount, actor)
  coroutine.yield('report', {
    type = 'text_rise',
    text_type = 'damage',
    body = body,
    amount = amount,
  })
end

return FX

