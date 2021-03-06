
-- luacheck: globals love

local WALL = {}

local SCHEMATICS  = require 'domain.definitions.schematics'
local VIEWDEFS    = require 'view.definitions'

local vec2        = require 'cpml' .vec2
local WallMesh    = require 'view.sector.mesh.wall'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H
local _MARGIN_W = 0
local _MARGIN_H = 0
local _BORDER_W = 8
local _BORDER_H = 6
local _GRID_W = 24
local _GRID_H = 18

local _TOPLEFT = vec2(0,0) -- luacheck: no unused
local _TOPRIGHT = vec2(_TILE_W, 0)
local _BOTLEFT = vec2(0, _TILE_H)
local _BOTRIGHT = vec2(_TILE_W, _TILE_H)

local _BACK_COLOR = {0x5b/256, 0x31/256, 0x38/256, 0.4}
local _FRONT_COLOR = {0x5b/256, 0x31/256, 0x38/256, 1}
local _FRONT_BRIGHT_COLOR  = {0x8e/256, 0x52/256, 0x52/256, 1}
local _FRONT_DARK_COLOR  = {0x42/256, 0x24/256, 0x33/256, 1}
local _BORDER_COLOR  = {0xba/256, 0x75/256, 0x6a/256, 1}
local _TOP_COLOR  = {0x14/256, 0x10/256, 0x13/256, 0.6}

local _W, _H

local _VTX_FORMAT = {
  {'VertexPosition', 'float', 2},
  {'Height', 'float', 1},
  {'VertexColor', 'float', 4},
}

local _VTXCODE = [[
uniform Image mask;
attribute number Height;

vec4 position(mat4 transform_projection, vec4 vertex_position) {
  vec4 h = Height * vec4(0, 1, 0, 0);
  vec4 pos = ProjectionMatrix * TransformMatrix * vertex_position;
  pos.y = -pos.y;
  VaryingColor *= Texel(mask, pos.xy/2 + 0.5);
  return transform_projection * (vertex_position+h);
}
]]
local _VTXSHADER

local _rowmeshes

local function _neighbors(sector, i, j)
  local neighbors = {}
  for r=1,3 do
    local di = r - 2
    neighbors[r] = {}
    for s=1,3 do
      local dj = s - 2
      neighbors[r][s] = sector:isInside(i + di, j + dj)
                        and sector:getTile(i + di, j + dj)
                        or false
    end
  end
  return neighbors
end

local function _empty(neighbors, r, s)
  return not neighbors[r][s] or neighbors[r][s].type ~= SCHEMATICS.WALL
end

local function _walled(neighbors, r, s)
  return neighbors[r][s] and neighbors[r][s].type == SCHEMATICS.WALL
end

local function _rect(left, right, top, bottom)
  return vec2(left, top), vec2(right, top), vec2(left, bottom),
         vec2(right, bottom)
end

local function _xform(off, sx, sy, v1, ...)
  if not v1 then return end
  return off + vec2(v1.x * sx, v1.y * sy), _xform(off, sx, sy, ...)
end

local function _pack(t)
  return function () return unpack(t) end
end

local _CORNER_HOR = _pack{ _rect(0, _GRID_W, _MARGIN_H + _BORDER_H, _GRID_H) }
local _CORNER_VER = _pack{ _rect(_MARGIN_W + _BORDER_W, _GRID_W, 0, _GRID_H) }
local _CORNER_OUT = _pack{ vec2(_MARGIN_W + _BORDER_W, _GRID_H),
                           vec2(_GRID_W, _MARGIN_H + _BORDER_H),
                           vec2(_GRID_W, _GRID_H) }
local _CORNER_INN = _pack{ vec2(0, _MARGIN_H + _BORDER_H),
                           vec2(_MARGIN_W + _BORDER_W, 0), vec2(0, _GRID_H),
                           vec2(_GRID_W, 0), vec2(_GRID_W, _GRID_H) }
local _CORNER_ALL = _pack{ _rect(0, _GRID_W, 0, _GRID_H) }

function WALL.load(sector)
  _W, _H = sector:getDimensions()
  _rowmeshes = {}
  if not _VTXSHADER then _VTXSHADER = love.graphics.newShader(_VTXCODE) end
  for i=1,_H do
    local vertices = {}
    local map = {}
    for j=1,_W do
      local neighbors = _neighbors(sector, i, j)
      local tile = sector:getTile(i,j)
      local wall = false
      if tile and tile.type == SCHEMATICS.WALL then
        local x0 = (j-1)*_TILE_W
        local y0 = 0
        wall = WallMesh:new { pos = vec2(x0,y0), border_color = _BORDER_COLOR }

        -- top
        if _empty(neighbors, 1, 2) then
          wall:addBottom(_rect(_GRID_W, _TILE_W - _GRID_W,
                                           _MARGIN_H + _BORDER_H, _GRID_H))
          wall:addSide(_BACK_COLOR, vec2(_GRID_W, _MARGIN_H),
                                    vec2(_TILE_W - _GRID_W, _MARGIN_H),
                                    vec2(0, _BORDER_H))
          wall:addTop(_TOP_COLOR, _rect(_GRID_W, _TILE_W - _GRID_W,
                                        _MARGIN_H + _BORDER_H, _GRID_H))
        else
          wall:addBottom(_rect(_GRID_W, _TILE_W - _GRID_W, 0,
                         _GRID_H))
          wall:addTop(_TOP_COLOR, _rect(_GRID_W, _TILE_W - _GRID_W, 0, _GRID_H))
        end

        -- topleft
        if _walled(neighbors, 2, 1) and _empty(neighbors, 1, 2) then
          -- straight left
          wall:addBottom(_CORNER_HOR())
          wall:addSide(_BACK_COLOR, vec2(0, _MARGIN_H),
                                    vec2(_GRID_W, _MARGIN_H),
                                    vec2(0, _BORDER_H))
          wall:addTop(_TOP_COLOR, _CORNER_HOR())
        elseif _walled(neighbors, 1, 2) and _empty(neighbors, 2, 1) then
          -- straight up
          wall:addBottom(_CORNER_VER())
          wall:addSide(nil, vec2(_MARGIN_W, 0), vec2(_MARGIN_W, _GRID_H),
                            vec2(_BORDER_W, 0))
          wall:addTop(_TOP_COLOR, _CORNER_VER())
        elseif _empty(neighbors, 2, 1) and _empty(neighbors, 1, 2) then
          -- outer corner
          wall:addBottom(_CORNER_OUT())
          wall:addSide(_BACK_COLOR, vec2(_MARGIN_W, _GRID_H),
                                    vec2(_GRID_W, _MARGIN_H),
                                    vec2(_BORDER_W, 0), vec2(0, _BORDER_H))
          wall:addTop(_TOP_COLOR, _CORNER_OUT())
        elseif _walled(neighbors, 2, 1) and _walled(neighbors, 1, 2) and
               _empty(neighbors, 1, 1) then
          -- inner corner
          wall:addBottom(_CORNER_INN())
          wall:addSide(_BACK_COLOR, vec2(0, _MARGIN_H), vec2(_MARGIN_W, 0),
                                    vec2(0, _BORDER_H), vec2(_BORDER_W, 0))
          wall:addTop(_TOP_COLOR, _CORNER_INN())
        else
          wall:addBottom(_CORNER_ALL())
          wall:addTop(_TOP_COLOR, _CORNER_ALL())
        end

        -- topright
        if _walled(neighbors, 2, 3) and _empty(neighbors, 1, 2) then
          -- straight right
          wall:addBottom(_xform(_TOPRIGHT, -1, 1, _CORNER_HOR()))
          wall:addSide(_BACK_COLOR, vec2(_TILE_W - _GRID_W, _MARGIN_H),
                                    vec2(_TILE_W, _MARGIN_H),
                                    vec2(0, _BORDER_H))
          wall:addTop(_TOP_COLOR, _xform(_TOPRIGHT, -1, 1, _CORNER_HOR()))
        elseif _walled(neighbors, 1, 2) and _empty(neighbors, 2, 3) then
          -- straight up
          wall:addBottom(_xform(_TOPRIGHT, -1, 1, _CORNER_VER()))
          wall:addSide(nil, vec2(_TILE_W - _MARGIN_W, 0),
                            vec2(_TILE_W - _MARGIN_W, _GRID_H),
                            vec2(-_BORDER_W, 0))
          wall:addTop(_TOP_COLOR, _xform(_TOPRIGHT, -1, 1, _CORNER_VER()))
        elseif _empty(neighbors, 1, 2) and _empty(neighbors, 2, 3) then
          -- outer corner
          wall:addBottom(_xform(_TOPRIGHT, -1, 1, _CORNER_OUT()))
          wall:addSide(_BACK_COLOR, vec2(_TILE_W - _MARGIN_W, _GRID_H),
                                    vec2(_TILE_W - _GRID_W, _MARGIN_H),
                                    vec2(-_BORDER_W, 0), vec2(0, _BORDER_H))
          wall:addTop(_TOP_COLOR, _xform(_TOPRIGHT, -1, 1, _CORNER_OUT()))
        elseif _walled(neighbors, 1, 2) and _walled(neighbors, 2, 3) and
               _empty(neighbors, 1, 3) then
          -- inner corner
          wall:addBottom(_xform(_TOPRIGHT, -1, 1, _CORNER_INN()))
          wall:addSide(_BACK_COLOR, vec2(_TILE_W, _MARGIN_H),
                                    vec2(_TILE_W - _MARGIN_W, 0),
                                    vec2(0, _BORDER_H), vec2(-_BORDER_W, 0))
          wall:addTop(_TOP_COLOR, _xform(_TOPRIGHT, -1, 1, _CORNER_INN()))
        else
          wall:addBottom(_xform(_TOPRIGHT, -1, 1, _CORNER_ALL()))
          wall:addTop(_TOP_COLOR, _xform(_TOPRIGHT, -1, 1, _CORNER_ALL()))
        end

        -- left
        if _empty(neighbors, 2, 1) then
          local border = vec2(_BORDER_W,0)
          wall:addBottom(_rect(_MARGIN_W + _BORDER_W, _GRID_W,
                                           _GRID_H, _TILE_H - _GRID_H))
          wall:addSide(nil, vec2(_MARGIN_W, _GRID_H),
                            vec2(_MARGIN_W, _TILE_H - _GRID_H), border)
          wall:addTop(_TOP_COLOR, _rect(_MARGIN_W + _BORDER_W, _GRID_W,
                                        _GRID_H, _TILE_H - _GRID_H))
        else
          wall:addBottom(_rect(0, _GRID_W, _GRID_H,
                         _TILE_H - _GRID_H))
          wall:addTop(_TOP_COLOR, _rect(0, _GRID_W, _GRID_H, _TILE_H - _GRID_H))
        end

        -- middle
        do
          wall:addBottom(_rect(_GRID_W, _TILE_W - _GRID_W, _GRID_H,
                                           _TILE_H - _GRID_H))
          wall:addTop(_TOP_COLOR, _rect(_GRID_W, _TILE_W - _GRID_W, _GRID_H,
                                        _TILE_H - _GRID_H))
        end

        -- right
        if _empty(neighbors, 2, 3) then
          local border = vec2(-_BORDER_W,0)
          wall:addBottom(_rect(_TILE_W - _GRID_W,
                                           _TILE_W - (_MARGIN_W + _BORDER_W),
                                           _GRID_H, _TILE_H - _GRID_H))
          wall:addSide(nil, vec2(_TILE_W - _MARGIN_W, _GRID_H),
                            vec2(_TILE_W - _MARGIN_W, _TILE_H - _GRID_H),
                            border)
          wall:addTop(_TOP_COLOR, _rect(_TILE_W - _GRID_W,
                                        _TILE_W - (_MARGIN_W + _BORDER_W),
                                        _GRID_H, _TILE_H - _GRID_H))
        else
          wall:addBottom(_rect(_TILE_W - _GRID_W, _TILE_W, _GRID_H,
                                           _TILE_H - _GRID_H))
          wall:addTop(_TOP_COLOR, _rect(_TILE_W - _GRID_W, _TILE_W, _GRID_H,
                                        _TILE_H - _GRID_H))
        end

        -- front
        if _empty(neighbors, 3, 2) then
          wall:addBottom(_rect(_GRID_W, _TILE_W - _GRID_W,
                                           _TILE_H - _GRID_H,
                                           _TILE_H - (_MARGIN_H + _BORDER_H)))
          wall:addSide(_FRONT_COLOR, _BOTLEFT + vec2(_GRID_W, -_MARGIN_H),
                                     _BOTRIGHT - vec2(_GRID_W, _MARGIN_H),
                                     vec2(0, -_BORDER_H))
          wall:addTop(_TOP_COLOR, _rect(_GRID_W, _TILE_W - _GRID_W,
                                        _TILE_H - _GRID_H,
                                        _TILE_H - (_MARGIN_H + _BORDER_H)))
        else
          wall:addBottom(_rect(_GRID_W, _TILE_W - _GRID_W,
                                           _TILE_H - _GRID_H , _TILE_H))
          wall:addTop(_TOP_COLOR, _rect(_GRID_W, _TILE_W - _GRID_W,
                                        _TILE_H - _GRID_H , _TILE_H))
        end

        -- bottomleft
        if _walled(neighbors, 2, 1) and _empty(neighbors, 3, 2) then
          -- straight left
          wall:addBottom(_xform(_BOTLEFT, 1, -1, _CORNER_HOR()))
          wall:addSide(_FRONT_COLOR, _BOTLEFT - vec2(0, _MARGIN_H),
                                     _BOTLEFT + vec2(_GRID_W, -_MARGIN_H),
                                     vec2(0, -_BORDER_H))
          wall:addTop(_TOP_COLOR, _xform(_BOTLEFT, 1, -1, _CORNER_HOR()))
        elseif _walled(neighbors, 3, 2) and _empty(neighbors, 2, 1) then
          -- straight down
          wall:addBottom(_xform(_BOTLEFT, 1, -1, _CORNER_VER()))
          wall:addSide(nil, _BOTLEFT + vec2(_MARGIN_W, -_GRID_H),
                            _BOTLEFT + vec2(_MARGIN_W, 0),
                            vec2(_BORDER_W, 0))
          wall:addTop(_TOP_COLOR, _xform(_BOTLEFT, 1, -1, _CORNER_VER()))
        elseif _empty(neighbors, 2, 1) and _empty(neighbors, 3, 2) then
          -- outer corner
          wall:addBottom(_xform(_BOTLEFT, 1, -1, _CORNER_OUT()))
          wall:addSide(_FRONT_BRIGHT_COLOR,
                       _BOTLEFT + vec2(_MARGIN_W, -_GRID_H),
                       _BOTLEFT + vec2(_GRID_W, -_MARGIN_H),
                       vec2(_BORDER_W, 0), vec2(0, -_BORDER_H))
          wall:addTop(_TOP_COLOR, _xform(_BOTLEFT, 1, -1, _CORNER_OUT()))
        elseif _walled(neighbors, 2, 1) and _walled(neighbors, 3, 2) and
               _empty(neighbors, 3, 1) then
          -- inner corner
          wall:addBottom(_xform(_BOTLEFT, 1, -1, _CORNER_INN()))
          wall:addSide(_FRONT_DARK_COLOR, _BOTLEFT + vec2(0, -_MARGIN_H),
                                          _BOTLEFT + vec2(_MARGIN_W, 0),
                                          vec2(0, -_BORDER_H),
                                          vec2(_BORDER_W, 0))
          wall:addTop(_TOP_COLOR, _xform(_BOTLEFT, 1, -1, _CORNER_INN()))
        else
          wall:addBottom(_xform(_BOTLEFT, 1, -1, _CORNER_ALL()))
          wall:addTop(_TOP_COLOR, _xform(_BOTLEFT, 1, -1, _CORNER_ALL()))
        end

        -- bottomright
        if _walled(neighbors, 2, 3) and _empty(neighbors, 3, 2) then
          -- straight right
          wall:addBottom(_xform(_BOTRIGHT, -1, -1, _CORNER_HOR()))
          wall:addSide(_FRONT_COLOR, _BOTRIGHT - vec2(0, _MARGIN_H),
                                     _BOTRIGHT - vec2(_GRID_W, _MARGIN_H),
                                     vec2(0, -_BORDER_H))
          wall:addTop(_TOP_COLOR, _xform(_BOTRIGHT, -1, -1, _CORNER_HOR()))
        elseif _walled(neighbors, 3, 2) and _empty(neighbors, 2, 3) then
          -- straight down
          wall:addBottom(_xform(_BOTRIGHT, -1, -1, _CORNER_VER()))
          wall:addSide(nil, _BOTRIGHT - vec2(_MARGIN_W, _GRID_H),
                            _BOTRIGHT - vec2(_MARGIN_W, 0),
                            vec2(-_BORDER_W, 0))
          wall:addTop(_TOP_COLOR, _xform(_BOTRIGHT, -1, -1, _CORNER_VER()))
        elseif _empty(neighbors, 2, 3) and _empty(neighbors, 3, 2) then
          -- outer corner
          wall:addBottom(_xform(_BOTRIGHT, -1, -1, _CORNER_OUT()))
          wall:addSide(_FRONT_DARK_COLOR, _BOTRIGHT - vec2(_MARGIN_W, _GRID_H),
                                          _BOTRIGHT - vec2(_GRID_W, _MARGIN_H),
                                          vec2(-_BORDER_W, 0),
                                          vec2(0, -_BORDER_H))
          wall:addTop(_TOP_COLOR, _xform(_BOTRIGHT, -1, -1, _CORNER_OUT()))
        elseif _walled(neighbors, 2, 3) and _walled(neighbors, 3, 2) and
               _empty(neighbors, 3, 3) then
          -- inner corner
          wall:addBottom(_xform(_BOTRIGHT, -1, -1, _CORNER_INN()))
          wall:addSide(_FRONT_BRIGHT_COLOR, _BOTRIGHT - vec2(0, _MARGIN_H),
                                            _BOTRIGHT - vec2(_MARGIN_W, 0),
                                            vec2(0, -_BORDER_H),
                                            vec2(-_BORDER_W, 0))
          wall:addTop(_TOP_COLOR, _xform(_BOTRIGHT, -1, -1, _CORNER_INN()))
        else
          wall:addBottom(_xform(_BOTRIGHT, -1, -1, _CORNER_ALL()))
          wall:addTop(_TOP_COLOR, _xform(_BOTRIGHT, -1, -1, _CORNER_ALL()))
        end
      end
      if wall then
        local n, m = #vertices, #map
        for k,vtx in ipairs(wall.vertices) do
          vertices[n+k] = vtx
        end
        for k,idx in ipairs(wall.faces) do
          map[m+k] = n+idx
        end
      end
    end
    if #vertices > 0 then
      local rowmesh = love.graphics.newMesh(_VTX_FORMAT, vertices, 'triangles',
                                            'static')
      rowmesh:setVertexMap(map)
      _rowmeshes[i] = rowmesh
    else
      _rowmeshes[i] = false
    end
  end
end

function WALL.drawRow(i, mask)
  local g = love.graphics
  _VTXSHADER:send('mask', mask)
  if _rowmeshes[i] then
    g.setShader(_VTXSHADER)
    g.draw(_rowmeshes[i])
    g.setShader()
  end
end

return WALL

