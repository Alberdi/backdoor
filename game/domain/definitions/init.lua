
local DEFS = {}

DEFS.DONE = "__DONE_VALUE__"
DEFS.DELETE = "__DELETE_VALUE__"
DEFS.CONSUME_EXP = 1
DEFS.NEW_HAND_COST = 10
DEFS.MAX_PP = 100
DEFS.PRIMARY_ATTRIBUTES = {"ATH", "ARC", "MEC"}
DEFS.ATTRIBUTES = {"ATH", "ARC", "MEC", "SPD"}
DEFS.BODY_ATTRIBUTES = {"HP", "DEF"}
DEFS.WIDGETS = {
  "WIDGET_A",
  "WIDGET_B",
  "WIDGET_C",
  "WIDGET_D",
}
DEFS.PACK_SIZE = 5
DEFS.HAND_LIMIT = 5
DEFS.TIME_UNIT = 10
DEFS.TIME_UNITS_PER_CHARGE = 1 * DEFS.TIME_UNIT

DEFS.BASIC_ABILITIES = {
  INTERACT = true,
  IDLE = true,
  MOVE = true,
  CHANGE_SECTOR = true,
}

return DEFS
