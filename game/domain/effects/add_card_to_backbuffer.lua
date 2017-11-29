
local DEFS = require 'domain.definitions'

local FX = {}

FX.schema = {
  { id = 'card', name = "Card", type = 'value', match = 'card' }, 
}

function FX.process (actor, params)
  actor:addCardToBackbuffer(params['card'])
end

return FX

