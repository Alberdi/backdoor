
-- dependencies
local SCHEMATICS = require 'domain.definitions.schematics'
local RANDOM     = require 'common.random'
local Vector2    = require 'cpml.modules.vec2'

local transformer = {}

transformer.schema = {
  { id = 'amount', name = "Total deadends", type = 'integer',
    range = { 0, 1024 } }
}

function transformer.process(sectorinfo, params)
  local _sectorgrid = sectorinfo.grid
  local _width, _height = _sectorgrid.getDim()
  local _mw, _mh = _sectorgrid.getMargins()

  local _minx = _mw + 1
  local _miny = _mh + 1
  local _maxx = _width - _mw
  local _maxy = _height - _mh

  local _corners = {}
  local _n = params.amount
  local _cardinals = {
    Vector2( 1,  0),
    Vector2( 0,  1),
    Vector2(-1,  0),
    Vector2( 0, -1)
  }

  local function isCorner(point)
    local FLOOR = SCHEMATICS.FLOOR
    local notwall = false
    local count = 0
    for i, dir in ipairs(_cardinals) do
      local pos = point + dir
      if _sectorgrid.get(pos.x, pos.y) ~= FLOOR then
        count = count + 1
      else
        notwall = pos
      end
    end
    if count == 3 then
      return notwall
    else
      return false
    end
  end

  local function cleanCorner(corner)
    local WALL = SCHEMATICS.WALL
    while corner and isCorner(corner) do
      _sectorgrid.set(corner.x, corner.y, WALL)
      corner = isCorner(corner)
    end
  end

  local function getDeadEnds()
    local FLOOR = SCHEMATICS.FLOOR
    local insert = table.insert
    for x = _minx, _maxx do
      for y = _miny, _maxy do
        local p = Vector2(x, y)
        if _sectorgrid.get(x, y) == FLOOR then
          if isCorner(p) then
            insert(_corners, p)
          end
        end
      end
    end
  end

  local function removeDeadEnds()
    local FLOOR = SCHEMATICS.FLOOR
    local corner
    local len = #_corners
    if len == 0 then return false end
    while len > 0 do
      local k = RANDOM.generate(1, len)

      corner = _corners[k]
      _corners[k] = _corners[len]
      _corners[len] = nil
      len = #_corners
      if isCorner(corner) then
        cleanCorner(corner)
      end
    end
    return true
  end

  for i = 1, _n do
    getDeadEnds()
    if not removeDeadEnds() then break end
  end

  return sectorinfo
end

return transformer

