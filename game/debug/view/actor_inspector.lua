
local IMGUI = require 'imgui'

return function (actor)

  return "Actor Inspector", 2, function(self)
    local hp = actor:getBody():getHP()
    self.sector_view:lookAt(actor)
    IMGUI.Text(("ID: %s"):format(actor:getId()))
    IMGUI.PushItemWidth(100)
    local changed, newhp = IMGUI.SliderInt("Hit Points", hp, 1,
                                           actor:getBody():getMaxHP())
    IMGUI.PopItemWidth()
    if changed then
      actor:getBody():setHP(newhp)
    end
    IMGUI.Text(("ATH: %d"):format(actor:getATH()))
    IMGUI.Text(("ARC: %d"):format(actor:getARC()))
    IMGUI.Text(("MEC: %d"):format(actor:getMEC()))
    IMGUI.Text(("SPD: %d"):format(actor:getSPD()))
  end

end
