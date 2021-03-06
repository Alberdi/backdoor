
-- luacheck: globals MAIN_TIMER love

local math    = require 'common.math'
local HoldBar = require 'view.helpers.holdbar'
local CARD    = require 'view.helpers.card'
local FONT    = require 'view.helpers.font'
local COLORS  = require 'domain.definitions.colors'
local RES     = require 'resources'
local DB      = require 'database'
local Class   = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"


-- MODULE -----------------------------------
local View = Class({
  __includes = ELEMENT
})

-- CONSTS -----------------------------------
local _EMPTY = {}
local _ENTER_TIMER = "manage_card_list_enter"
local _ENTER_SPEED = .2
local _MOVE_SMOOTH = 1/5
local _EPSILON = 2e-5
local _SIN_INTERVAL = 1/2^5
local _PD = 40
local _ARRSIZE = 20
local _PI = math.pi
local _HOLDBAR_TEXT1 = "open pack"
local _HOLDBAR_TEXT2 = "open all packs"
local _WIDTH, _HEIGHT
local _CW, _CH

-- LOCAL VARS
local _font
local _controls_font

-- LOCAL METHODS ----------------------------
local function _initGraphicValues()
  local g = love.graphics
  _WIDTH, _HEIGHT = g.getDimensions()

  _font = FONT.get("TextBold", 20)
  _controls_font = FONT.get("Text", 25)
  _CW = CARD.getWidth() + 20
  _CH = CARD.getHeight() + 20
end

local function _next_circular(i, len, n)
  if n == 0 then return i end
  return _next_circular(i % len + 1, len, n - 1)
end

local function _prev_circular(i, len, n)
  if n == 0 then return i end
  return _prev_circular((i - 2) % len + 1, len, n - 1)
end

local function _renderControls(g, alpha)
  g.push()
  g.translate(15, 676)

  _controls_font:set()
  local c = COLORS.NEUTRAL
  g.setColor(c[1], c[2], c[3], alpha)
  local text = "S to cancel"
  g.print(text, 0, 0)

  g.pop()
end
-- PUBLIC METHODS ---------------------------
function View:init(hold_actions_single, hold_actions_all, packlist)
  ELEMENT.init(self)

  self.enter = 0
  self.text = 0
  self.selection = math.ceil(#packlist/2)
  self.cursor = 0

  self.y_offset = {}
  for i=1,#packlist do self.y_offset[i] = 0 end

  self.move = self.selection
  self.offsets = {}
  self.pack_list = packlist

  self.holdbar_single = HoldBar(hold_actions_single)
  self.holdbar_single:unlock()
  self.holdbar_single_activated = false

  if #self.pack_list > 1 then
    self.holdbar_all = HoldBar(hold_actions_all)
    self.holdbar_all:unlock()
    self.holdbar_all_activated = false
  end

  self:removeTimer(_ENTER_TIMER, MAIN_TIMER)
  self:addTimer(_ENTER_TIMER, MAIN_TIMER, "tween",
                _ENTER_SPEED, self, { enter=1, text=1 }, "out-quad")

  _initGraphicValues()
end

function View:isLocked()
  if #self.pack_list > 1 then
    return self.holdbar_single:isLocked() or self.holdbar_all:isLocked()
  else
    return self.holdbar_single:isLocked()
  end
end

function View:lockHoldbar()
  self.holdbar_single:lock()
  if #self.pack_list > 1 then
    self.holdbar_all:lock()
  end
end

function View:unlockHoldbar()
  self.holdbar_single:unlock()
  if #self.pack_list > 1 then
    self.holdbar_all:unlock()
  end
end

function View:getChosenPack()
  return self.pack_list[self.selection]
end

function View:getAllPacks()
  return self.pack_list
end

function View:close()
  self.holdbar_single:lock()
  if #self.pack_list > 1 then
    self.holdbar_all:lock()
  end
  self:removeTimer(_ENTER_TIMER, MAIN_TIMER)
  self:addTimer(_ENTER_TIMER, MAIN_TIMER, "tween",
                _ENTER_SPEED, self, { enter=0, text=0 }, "out-quad",
                function ()
                  self.pack_list = _EMPTY
                  self:destroy()
                end)
end

function View:selectPrev(n)
  if self:isLocked() then return end
  n = n or 1
  self.selection = _prev_circular(self.selection, #self.pack_list, n)
  self.holdbar_single:reset()
  if #self.pack_list > 1 then
    self.holdbar_all:reset()
  end
end

function View:selectNext(n)
  if self:isLocked() then return end
  n = n or 1
  self.selection = _next_circular(self.selection, #self.pack_list, n)
  self.holdbar_single:reset()
  if #self.pack_list > 1 then
    self.holdbar_all:reset()
  end
end

function View:setSelection(n)
  self.selection = n
end

function View:getSelection()
  return self.selection
end

function View:isPackListEmpty()
  return #self.pack_list == 0
end

function View:draw()
  local g = love.graphics
  local enter = self.enter
  g.push()

  if enter > 0 then
    self:drawBG(g, enter)
    self:drawPacks(g, enter)
    _renderControls(g, enter)
  end

  g.pop()
end

function View:drawBG(g, enter) -- luacheck: no self
  g.setColor(0, 0, 0, enter*0.95)
  g.rectangle("fill", 0, 0, _WIDTH, _HEIGHT)
end

function View:drawPacks(g, enter)
  local selection = self.selection
  local pack_list = self.pack_list
  local pack_list_size = #pack_list

  g.push()

  -- smooth enter!
  g.translate(math.round((_WIDTH/2)*(1-enter)+_WIDTH/2-_CW/2),
              math.round(3*_HEIGHT/7-_CH/2))

  -- smooth movement!
  self.move = self.move + (selection - self.move)*_MOVE_SMOOTH
  if (self.move-selection)^2 <= _EPSILON then self.move = selection end
  g.translate(math.round(-(_CW+_PD)*(self.move-1)), 0)

  -- draw each pack
  for i = 1, pack_list_size do
    g.push()
    local collection = DB.loadSpec("collection", pack_list[i])
    local focus = selection == i
    local offset = self.offsets[i] or 0

    -- smooth offset when consuming pack
    offset = offset > _EPSILON and offset - offset * _MOVE_SMOOTH or 0
    self.offsets[i] = offset
    g.translate((_CW+_PD)*(i-1+offset), 0)
    g.translate(0, self.y_offset[i])
    local packbg = RES.loadTexture("pack")

    local shiny = focus and 1.2 or 1

    --shadow
    g.setColor(0, 0, 0, 200/255)
    g.draw(packbg, 5, 5)

    --pack
    local br, bg, bb
    assert(COLORS["PACK_"..collection.pack_color], "Not a valid pack color: "..collection.pack_color)
    br, bg, bb = unpack(COLORS["PACK_"..collection.pack_color])

    g.setColor(br*shiny, bg*shiny, bb*shiny)
    g.draw(packbg, 0, 0)

    --draw icon
    local icon = RES.loadTexture(collection.image)

    if collection.icon_color == "white" then
      br, bg, bb = unpack(COLORS.NEUTRAL)
    elseif collection.icon_color == "black" then
      br, bg, bb = unpack(COLORS.DARK)
    else
      assert(false, "Not a valid icon_color: "..collection.icon_color)
    end

    g.setColor(br, bg, bb)
    g.draw(icon,15,55, nil, .5)
    g.pop()
  end
  g.pop()

  -- draw selection
  g.push()
  g.translate(math.round(_WIDTH/2),
              math.round(3*_HEIGHT/7-_CH/2))
  enter = self.text
  if enter > 0 then
    self:drawArrows(g, enter)
    if pack_list[selection] then
      self:drawPackDesc(g, pack_list[selection], enter)
    end
  end

  g.pop()
end

function View:drawArrows(g, enter)
  local lh = 1.25
  local text_height
  local senoid

  g.push()

  -- move arrow in senoid
  self.cursor = self.cursor + _SIN_INTERVAL
  while self.cursor > 1 do self.cursor = self.cursor - 1 end
  senoid = (_ARRSIZE/2)*math.sin(self.cursor*_PI)

  _font:setLineHeight(lh)
  _font.set()
  text_height = _font:getHeight()*lh

  g.translate(0, -_PD - text_height*2.5)

  g.push()
  --Up info
  self:drawHoldBar("single")
  local text_width = _font:getWidth(_HOLDBAR_TEXT1)
  g.translate(0, text_height*.5)
  g.setColor(1, 1, 1, enter)
  g.printf(_HOLDBAR_TEXT1, -text_width/2, 0, text_width, "center")

  g.translate(-_ARRSIZE/2, _PD + text_height - _ARRSIZE/2 - senoid)
  g.polygon("fill", 0, 0, _ARRSIZE/2, -_ARRSIZE, _ARRSIZE, 0)
  g.pop()

  if #self.pack_list > 1 then
    --Down info
    text_width = _font:getWidth(_HOLDBAR_TEXT2)
    g.translate(0, _CH + _PD + text_height*5)
    g.setColor(1, 1, 1, enter)
    g.printf(_HOLDBAR_TEXT2, -text_width/2, 0, text_width, "center")

    g.translate(-_ARRSIZE/2, -text_height*1.5 + _ARRSIZE + senoid)
    g.polygon("fill", 0, 0, _ARRSIZE/2, _ARRSIZE, _ARRSIZE, 0)

    g.translate(_ARRSIZE/2, _ARRSIZE + text_height*1.5 - senoid)
    self:drawHoldBar("all")
  end

  g.pop()
end

function View:drawPackDesc(g, pack, enter) -- luacheck: no unused
  g.push()
  g.translate(-1.5*_CW, _CH+_PD)
  -- FIXME
  --CARD.drawInfo(card, 0, 0, 4*_CW, enter)
  g.pop()
end

function View:usedHoldbar()
  if self.holdbar_single_activated then
    return true, "single"
  elseif #self.pack_list > 1 and self.holdbar_all_activated then
    return true, "all"
  else
    return false
  end
end

function View:drawHoldBar(type)
  local holdbar
  if type == "single" then
    holdbar = self.holdbar_single
  elseif type == "all" then
    holdbar = self.holdbar_all
  else
    error("Not a valid holdbar type: "..type)
  end
  holdbar:update()
  if holdbar:confirmed() then
    self["holdbar_"..type.."_activated"] = true
  end
  holdbar:draw(0, 0)
end

return View
