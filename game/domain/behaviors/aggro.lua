
local DIR = require 'domain.definitions.dir'
local Action = require 'domain.action'
local TILE = require 'common.tile'
local Heap = require 'common.heap'

local abs = math.abs
local VISION = 20 -- high value to test heap efficiency
local DEDICATION = math.floor(VISION * math.sqrt(2))

local function _hash(pos)
  if not pos then return "none" end
  return string.format("%d:%d", unpack(pos))
end

local function _heuristic(pos1, pos2)
  local i1, j1 = unpack(pos1)
  local i2, j2 = unpack(pos2)
  return abs(i1 - i2) + abs(j2 - j2)
end

local function _findPath(start, goal, sector)
  local frontier = Heap:new()
  local came_from = {}
  local cost_so_far = {}
  local path = {}
  local found = false
  local count = 0

  frontier:add(start, 0)
  came_from[_hash(start)] = true
  cost_so_far[_hash(start)] = 0

  while not frontier:isEmpty() do
    count = count + 1
    local current, rank = frontier:getNext()

    -- if you found your goal, quit loop
    if TILE.distUniform(goal[1], goal[2], unpack(current)) == 1 then
      found = true
      goal = current
      break
    end

    -- look at neighbors
    for _,dir in ipairs(DIR) do
      local di, dj = unpack(DIR[dir])
      local i, j = unpack(current)
      local ti, tj = unpack(goal)
      local next_pos = { i+di, j+dj }
      local distance = _heuristic(goal, next_pos)

      if sector:isValid(unpack(next_pos)) and distance < DEDICATION then
        local new_cost = cost_so_far[_hash(current)] + 1

        -- is it a valid and not yet checked neighbor?
        if not cost_so_far[_hash(next_pos)]
          or new_cost < cost_so_far[_hash(next_pos)] then
          local new_rank = new_cost + 2 * distance
          cost_so_far[_hash(next_pos)] = new_cost
          came_from[_hash(next_pos)] = current
          frontier:add(next_pos, new_rank)
        end
      end
    end
  end

  local current = goal
  if found then
    while _hash(start) ~= _hash(current) do
      table.insert(path, current)
      current = came_from[_hash(current)]
    end
    return path[#path], count
  end
  return false, count
end

return function (actor, sector)
  local actorlist = sector:getActors()
  local target, dist
  local i, j = actor:getPos()

  -- create list of opponents
  for _,opponent in ipairs(actorlist) do
    if opponent:isPlayer() then
      local k, l = opponent:getPos()
      local d = TILE.distUniform(i, j, k, l)
      if not target or not dist or d < dist then
        target = opponent
        dist = d
      end
    end
  end

  if dist == 1 then
    -- attack if close!
    return 'PRIMARY', { target = {target:getPos()} }
  elseif dist <= VISION then
    -- chase if far away!
    local start = os.clock()
    local pos, operations = _findPath({i,j}, {target:getPos()}, sector)
    print(("%.10f, %d operations"):format(os.clock() - start, operations))
    if pos then
      return 'MOVE', { pos = pos }
    end
  end

  return 'IDLE', {}
end

