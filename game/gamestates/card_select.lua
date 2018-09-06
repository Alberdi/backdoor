--MODULE FOR THE GAMESTATE: SELECTING A CARD IN HAND--
local INPUT = require 'input'
local DIRECTIONALS = require 'infra.dir'
local PLAYSFX        = require 'helpers.playsfx'

local state = {}


--LOCAL VARIABLES--

local _route
local _actor_view
local _hand_view

--LOCAL FUNCTIONS--

local function _moveFocus(dir)
  _hand_view:moveFocus(dir)
end

local function _changeActionType(dir)
  _hand_view:changeActionType(dir)
end

local function _confirmCard()
  local args = {
    chose_a_card = true,
    action_type = _hand_view:getActionType(),
    card_index = _hand_view:getFocus(),
  }
  if args.card_index > _route.getControlledActor():getHandSize() then
    args.card_index = 'draw-hand'
  end
  SWITCHER.pop(args)
end

local function _cancel()
  local args = {
    chose_a_card = false,
  }
  PLAYSFX 'back-menu'
  _hand_view:deactivate()
  SWITCHER.pop(args)
end

--STATE FUNCTIONS--

function state:init()
end

function state:enter(_, route, _view)

  _route = route
  _hand_view = _view.hand
  if not _hand_view:isActive() then
    _hand_view:activate()
  end
  _hand_view.cardinfo:show()
  _actor_view = _view.actor
  _actor_view.onhandview = true

  --Make cool animation for cards showing up

end

function state:leave()

  _actor_view.onhandview = false
  _hand_view.cardinfo:hide()

end

function state:update(dt)

  if DEBUG then return end

  if DIRECTIONALS.wasDirectionTriggered('RIGHT') then
    _moveFocus("RIGHT")
  elseif DIRECTIONALS.wasDirectionTriggered('LEFT') then
    _moveFocus("LEFT")
  elseif DIRECTIONALS.wasDirectionTriggered('UP') then
    _changeActionType("UP")
  elseif DIRECTIONALS.wasDirectionTriggered('DOWN') then
    _changeActionType("DOWN")
  elseif INPUT.wasActionPressed('CONFIRM') then
    _confirmCard()
  elseif INPUT.wasActionPressed('CANCEL') or
    INPUT.wasActionPressed('ACTION_1') or
    INPUT.wasActionPressed('SPECIAL') then
    _cancel()
  end

  Util.destroyAll()

end

function state:draw()

    Draw.allTables()

end

--Return state functions
return state
