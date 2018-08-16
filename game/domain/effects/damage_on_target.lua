
local RANDOM  = require 'common.random'
local ATTR    = require 'domain.definitions.attribute'
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'base', name = "Base Power", type = 'integer',
    range = {1} },
  { id = 'attr', name = "Mod Power", type = 'value',
    match = 'integer', range = {1} },
  { id = 'sfx', name = "SFX", type = 'enum',
    options = 'resources.sfx',
    optional = true },
}

function FX.preview (actor, fieldvalues)
  local attr, base = fieldvalues.attr, fieldvalues.base
  local amount = ATTR.EFFECTIVE_POWER(base, attr)
  return ("Deal %s damage to target"):format(amount)
end

function FX.process (actor, fieldvalues)
  local attr, base = fieldvalues.attr, fieldvalues.base
  local amount = ATTR.EFFECTIVE_POWER(base, attr)
  local dmg = fieldvalues.target:takeDamageFrom(amount, actor)

  coroutine.yield('report', {
    type = 'text_rise',
    text_type = 'damage',
    body = fieldvalues['target'],
    amount = dmg,
    sfx = fieldvalues.sfx,
  })
end

return FX
