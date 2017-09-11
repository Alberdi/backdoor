
local PARAM = {}

PARAM.schema = {
  { id = 'max-range', name = "Maximum range", type = 'value', match = 'integer',
    range = {1} },
  { id = 'filter', name = "Filter", type = 'enum',
    options = { 'BODY', 'ANY' } },
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'body'

function PARAM.isValid(sector, actor, value)
  return true
end

return PARAM

