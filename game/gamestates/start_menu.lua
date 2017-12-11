--MODULE FOR THE GAMESTATE: MAIN MENU--
local DB = require 'database'
local MENU = require 'infra.menu'
local INPUT = require 'input'
local PROFILE = require 'infra.profile'
local StartMenuView = require 'view.startmenu'

local state = {}

--LOCAL VARIABLES--

local _menu_view
local _menu_context
local _mapping

--LOCAL FUNCTIONS--

local function _title()
end

--STATE FUNCTIONS--

function state:init()
  _mapping = {
    PRESS_CONFIRM  = MENU.confirm,
    PRESS_SPECIAL  = MENU.cancel,
    PRESS_CANCEL   = MENU.cancel,
    PRESS_QUIT     = MENU.cancel,
    PRESS_UP       = MENU.prev,
    PRESS_DOWN     = MENU.next,
  }
end

function state:enter()
  _menu_view = StartMenuView()
  _menu_view:addElement("GUI", nil, "menu_view")
  _menu_view:open()
  _menu_context = "START_MENU"
end

function state:leave()
  _menu_view:destroy()
  _menu_view = nil
end

function state:resume(from, player_info)
  if player_info then
    local route_data = PROFILE.newRoute(player_info)

    local species, background
    species = player_info.species
    background = player_info.background
    print(string.format("selected %s %s", species, background))

    SWITCHER.switch(GS.PLAY, route_data)
  else
    _menu_view:open()
    _menu_context = "START_MENU"
  end
end

function state:update(dt)
  MAIN_TIMER:update(dt)

  if INPUT.wasActionPressed('CONFIRM') then MENU.confirm()
  elseif INPUT.wasActionPressed('SPECIAL') then MENU.cancel()
  elseif INPUT.wasActionPressed('CANCEL') then MENU.cancel()
  elseif INPUT.wasActionPressed('QUIT') then MENU.cancel()
  elseif INPUT.wasActionPressed('UP') then MENU.prev()
  elseif INPUT.wasActionPressed('DOWN') then MENU.next()
  end

  _menu_view.invisible = false
  if _menu_context == "START_MENU" then
    _menu_view:setItem("New route")
    _menu_view:setItem("Load route")
    _menu_view:setItem("Quit")
  elseif _menu_context == "LOAD_LIST" then
    local savelist = PROFILE.getSaveList()
    if next(savelist) then
      for route_id, route_header in pairs(savelist) do
        local savename = ("%s %s"):format(route_id, route_header.player_name)
        _menu_view:setItem(savename)
      end
    else
      _menu_view:setItem("[ NO DATA ]")
    end
  end
  if MENU.begin(_menu_context) then
    if _menu_context == "START_MENU" then
      if MENU.item("New route") then
        _menu_view:close(function()
          SWITCHER.push(GS.CHARACTER_BUILD)
        end)
      end
      if MENU.item("Load route") then
        _menu_context = "LOAD_LIST"
      end
      if MENU.item("Quit") then
        _menu_view:close(love.event.quit)
      end
    elseif _menu_context == "LOAD_LIST" then
      local savelist = PROFILE.getSaveList()
      if next(savelist) then
        for route_id, route_header in pairs(savelist) do
          local savename = ("%s %s"):format(route_id, route_header.player_name)
          if MENU.item(savename) then
            SWITCHER.switch(GS.PLAY, PROFILE.loadRoute(route_id))
          end
        end
      else
        if MENU.item("[ NO DATA ]") then
          print("Cannot load no data.")
        end
      end
    end
  else
    if _menu_context == "START_MENU" then
      _menu_view:close(love.event.quit)
    elseif _menu_context == "LOAD_LIST" then
      _menu_context = "START_MENU"
    end
  end
  MENU.finish()
  _menu_view:setSelection(MENU.getSelection())
  _title()
end

function state:draw()
  Draw.allTables()
end

--Return state functions
return state

