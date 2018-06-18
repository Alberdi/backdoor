
--- GAMESTATE: Choosing an action

local INPUT          = require 'input'
local DIRECTIONALS   = require 'infra.dir'
local PLAYSFX        = require 'helpers.playsfx'
local ActionMenuView = require 'view.actionmenu'

local state = {}

--[[ LOCAL VARIABLES ]]--

local _menu_view
local _last_focus

--[[ LOCAL FUNCTIONS ]]--

local function _moveFocus(dir)
  PLAYSFX 'select-menu'
  _menu_view:moveFocus(dir)
end

local function _confirm()
  _last_focus = _menu_view:getCurrentFocus()
  _menu_view:close()
  SWITCHER.pop({ action = _menu_view:getSelected() })
end

local function _cancel()
  _last_focus = _menu_view:getCurrentFocus()
  _menu_view:close()
  PLAYSFX 'back-menu'
  SWITCHER.pop({})
end

--[[ STATE FUNCTIONS ]]--

function state:init()
  _menu_view = ActionMenuView()
  _menu_view:addElement('HUD')
end

function state:enter(_, route)

  local player = route.getControlledActor()
  _menu_view:open(_last_focus, player)

end

function state:leave()
end

function state:update(dt)
  if DEBUG then return end

  MAIN_TIMER:update(dt)

  if DIRECTIONALS.wasDirectionTriggered('UP') then
    _moveFocus('UP')
  elseif DIRECTIONALS.wasDirectionTriggered('UPLEFT') then
    _moveFocus('UPLEFT')
  elseif DIRECTIONALS.wasDirectionTriggered('LEFT') then
    _moveFocus('LEFT')
  elseif DIRECTIONALS.wasDirectionTriggered('DOWN') then
    _moveFocus('DOWN')
  elseif DIRECTIONALS.wasDirectionTriggered('DOWNRIGHT') then
    _moveFocus('DOWNRIGHT')
  elseif DIRECTIONALS.wasDirectionTriggered('RIGHT') then
    _moveFocus('RIGHT')
  elseif INPUT.wasActionPressed('CONFIRM') then
    _confirm()
  elseif INPUT.wasActionPressed('CANCEL') or
         INPUT.wasActionPressed('EXTRA') then
    _cancel()
  end

end

function state:draw()

  Draw.allTables()

end

return state
