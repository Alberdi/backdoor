
local ACTIONDEFS = require 'domain.definitions.action'
local IDLE = {}

IDLE.param_specs = {}

function IDLE.activatedAbility(actor, inputvalues)
  return nil
end

function IDLE.validate(actor, inputvalues)
  return true
end

function IDLE.perform(actor, inputvalues)
  actor:exhaust(ACTIONDEFS.IDLE_COST)
end

return IDLE

