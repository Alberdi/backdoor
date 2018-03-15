
local FX = {}

FX.schema = {
  { id = 'body', name = "Body", type = 'value', match = 'body' },
  { id = 'pos', name = "Position", type = 'value', match = 'pos' },
  { id = 'vfx', name = "Visual Effect", type = 'enum',
    options = { 'SLIDE', 'JUMP' } },
  { id = 'vfx-spd', name ="Animation Speed", type = 'float',
    range = {0.1, 10.0}, default = 1.0 }
}

function FX.process (actor, fieldvalues)
  local pos = {actor:getPos()}
  local body = fieldvalues['body']
  local target_pos = fieldvalues['pos']
  if pos[1] == target_pos[1] and pos[2] == target_pos[2] then
    return
  end
  local sector = body:getSector()
  sector:putBody(body, unpack(target_pos))
  if fieldvalues['vfx'] == 'SLIDE' then
    coroutine.yield('report', {
      type = 'body_moved',
      body = body,
      origin = pos,
      speed_factor = fieldvalues['vfx-spd']
    })
  elseif fieldvalues['vfx'] == 'JUMP' then
    coroutine.yield('report', {
      type = 'body_jumped',
      body = body,
      origin = pos,
      speed_factor = fieldvalues['vfx-spd']
    })
  end
end

return FX

