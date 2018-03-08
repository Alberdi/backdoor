
local math = require 'common.math'

local FX = {}

FX.schema = {
  { id = 'percentage', name = "HP Percentage", type = 'integer',
    range = {1, 90}
  },
  { id = 'stay_alive', name = "Stay Alive?", type = 'boolean' },
}

-- can be for self-damaging attacks, as well as effects like poison

function FX.process (actor, params)
  local body = actor:getBody()
  local current_hp = body:getHP()
  local max_hp = body:getMaxHP()
  local amount = math.round(max_hp*params.percentage/100)
  if params.stay_alive then
    amount = math.min(current_hp - 1, amount)
  end
  local dmg = body:takePiercedDamageFrom(amount, actor)
  coroutine.yield('report', {
    type = 'dmg_taken',
    body = body,
    amount = amount,
  })
end

return FX
