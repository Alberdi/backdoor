
local Card = require 'domain.card'
local DB = require 'database'

local FX = {}

FX.schema = {
  { id = 'body', name = "Target Body", type = 'value', match = "body" },
  { id = 'card', name = "Card Specname", type = 'enum',
    options = "domains.card" },
}

function FX.preview(_, fieldvalues)
  local name = DB.loadSpec('card', fieldvalues['card'])['name']
  return ("cause %s to %s"):format(name, fieldvalues['body'])
end

function FX.process(actor, fieldvalues)
  local card = Card(fieldvalues['card'])
  local body = fieldvalues['body']
  card:setOwner(actor)
  body:placeWidget(card)
  coroutine.yield('report', {
    type = 'place_widget_card',
    body = body,
    card = card,
    sfx = fieldvalues.sfx,
  })
end

return FX
