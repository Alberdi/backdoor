--DEPENDENCIES--
local RES    = require 'resources'
local FONT   = require 'view.helpers.font'
local COLORS = require 'domain.definitions.colors'
local Queue  = require 'lux.common.Queue'

--CLASS VIEW--
local StartMenuView = Class{
  __includes = { ELEMENT }
}

local _TITLE_TEXT = "backdoor"
local _LH = 1.5
local _TILE_W, _TILE_H = 80, 80

local _SCROLL_THRESHOLD = 6
local _TITLE_FONT_SIZE = 48
local _MENU_FONT_SIZE = 24
local _FADE_TIME = .5

--Logo consts and variables
local _LOGO_BG_PARTS = 11
local _LOGO_BG = {}
local _LOGO_BG_OX = 478 --X value for image center
local _LOGO_BG_OY = 324 --y value for image center
local _LOGO_BG_OFFSET = {} --Offset for each part
local _LOGO_BG_MAGNITUDE = {} --Magnitude of offset for each part
local _LOGO_TEXT
local _LOGO_ROTATION_SPEED = .05
local _logo_rotation = 0

local _menu_font, _title_font
local _width, _height

local function _initFontValues()
  local g = love.graphics
  _title_font = _title_font or FONT.get("Title", _TITLE_FONT_SIZE)
  _menu_font = _menu_font or FONT.get("Text", _MENU_FONT_SIZE)
  _width, _height = g.getDimensions()
end

local function _initLogo()
  for i = 1, _LOGO_BG_PARTS do
    _LOGO_BG[i] = RES.loadTexture('logo-bg'..i)
    _LOGO_BG[i]:setFilter("linear","linear")
    _LOGO_BG_OFFSET[i] = love.math.random(0,2*math.pi)
    _LOGO_BG_MAGNITUDE[i] = love.math.random()*1 + 1 --Random float [1,2]
  end
  _LOGO_TEXT = RES.loadTexture('logo-text')
  _LOGO_BG_WIDTH = _LOGO_BG[1]:getWidth()
  _LOGO_BG_HEIGHT = _LOGO_BG[1]:getHeight()
end

local function _renderTitle(g)
  g.push()
  g.translate(-_width/8, -_height/8)
  g.setColor(COLORS.NEUTRAL)
  local x, y = 480,360
  --Draw center without offset
  g.draw(_LOGO_BG[1], x, y, _logo_rotation, nil, nil,
        _LOGO_BG_OX, _LOGO_BG_OY)
  --Draw all other parts with offset
  for i = 2, _LOGO_BG_PARTS do
    local offx = math.cos(_LOGO_BG_OFFSET[i])*_LOGO_BG_MAGNITUDE[i]
    local offy = math.sin(_LOGO_BG_OFFSET[i])*_LOGO_BG_MAGNITUDE[i]
    g.draw(_LOGO_BG[i],x+offx, y+offy, _logo_rotation, nil, nil,
          _LOGO_BG_OX, _LOGO_BG_OY)
  end
  g.draw(_LOGO_TEXT,-20,120)
  g.pop()
end


local function _renderOptions(g, q, selection, scrolltop)
  g.push()
  g.translate(320, 450)
  _menu_font:set()
  _menu_font:setLineHeight(_LH)
  local count = 0
  while not q.isEmpty() do
    local item_text = q.pop()
    local text_color = COLORS.BACKGROUND
    count = count + 1
    if count >= scrolltop and count < scrolltop + _SCROLL_THRESHOLD then
      if selection == count then
        text_color = COLORS.NEUTRAL
      end
      g.setColor(text_color)
      g.print(item_text, -_menu_font:getWidth(item_text)/2, 0)
      g.translate(0, _menu_font:getHeight())
    end
  end
  g.pop()
end


function StartMenuView:init()

  ELEMENT.init(self)

  self.queue = Queue(128)
  self.title = "backdoor"
  self.selection = 1
  self.scrolltop = 1

  _initFontValues()

  _initLogo()

end

function StartMenuView:setItem(item_text)
  self.queue.push(item_text)
end


function StartMenuView:setSelection(n)
  if n < self.scrolltop then
    self.scrolltop = n
  end
  if n >= self.scrolltop + _SCROLL_THRESHOLD then
    self.scrolltop = n - _SCROLL_THRESHOLD + 1
  end
  self.selection = n
end


function StartMenuView:draw()

  local g = love.graphics
  local q = self.queue

  g.push()
  g.setBackgroundColor(0, 0, 0)
  g.translate(4*_TILE_W, 0)

  _renderTitle(g)
  _renderOptions(g, q, self.selection, self.scrolltop)

  g.pop()

end

function StartMenuView:update(dt)

  _logo_rotation = (_logo_rotation + _LOGO_ROTATION_SPEED*dt)
  for i = 2, _LOGO_BG_PARTS do
    _LOGO_BG_OFFSET[i] = _LOGO_BG_OFFSET[i] + dt
  end

end



return StartMenuView
