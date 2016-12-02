
extends "res://game/database/cards/components/step.gd"

const Effect = preload("res://game/database/cards/components/effect.gd")

onready var effects = get_children()

func _ready():
  for effect in effects:
    assert(effect extends Effect)

func execute(actor, card, target):
  var map = get_current_sector()
  var body = map.get_body_at(target)
  var options = { "target_body": body }
  for effect in effects:
    effect.execute(actor, card, options)
