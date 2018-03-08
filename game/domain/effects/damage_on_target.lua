
local RANDOM = require 'common.random'
local FX = {}

FX.schema = {
  {
    id = 'attr', name = "Attribute", type = 'value',
    match = 'integer', range = {1}
  },
  { id = 'base', name = "Base Power", type = 'value',
    match = 'integer', range = {1} },
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'sfx', name = "SFX", type = 'enum',
    options = 'resources.sfx',
    optional = true },
}

function FX.process (actor, params)
  local amount = RANDOM.rollDice(params.base, params.attr)
  local dmg = params.target:takeDamageFrom(amount, actor)

  coroutine.yield('report', {
    type = 'dmg_taken',
    body = params['target'],
    amount = dmg,
    sfx = params.sfx,
  })
end

return FX