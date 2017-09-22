
local FX = {}

FX.schema = {
  { id = 'value', name = "Modify Exp By", type = 'value', match = 'integer' },
}

function FX.process(actor, sector, params)
  actor:modifyExpBy(params.value)
end

return FX

