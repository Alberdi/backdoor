
extends Control

const MenuButton = preload("res://components/ui/save-button.tscn")

const Route = preload("res://model/route.gd")

onready var loading = get_node("/root/loading")
onready var transition = get_node("/root/transition")
onready var saves_node = get_node("saves")
onready var controller = get_node("controller")
onready var database = get_node("/root/database")
onready var profile = database.get_profile()

func _ready():
  start()

func start():
  var journals = profile.get_journals()
  for route_id in journals:
    var char_name = profile.get_player_name(route_id)
    var button = MenuButton.instance()
    button.set_text(char_name)
    button.connect("selected", self, "_on_load_game_selected", [route_id])
    saves_node.add_child(button)
  show()
  transition.unfade_from_black(.5)
  yield(transition, "end_fadein")
  controller.setup()

func stop():
  hide()
  loading.start()
  for button in saves_node.get_children():
    if button.get_name() != "new_game" and button.get_name() != "cursor":
      button.queue_free()

func stop_controller():
  controller.disable()

func transition_out():
  transition.configure_fadeout(self, "stop_controller", self, "stop")

func _on_new_game_selected():
  print("new game selected!")
  transition_out()
  transition.fade_to_black(.5)
  yield(transition, "end_fadeout")
  transition.unfade_from_black(.5)
  yield(transition, "end_fadein")
  database.create_route()


func _on_load_game_selected(save_id):
  print("load game selected!")
  transition_out()
  transition.fade_to_black(.5)
  yield(transition, "end_fadeout")
  transition.unfade_from_black(.5)
  yield(transition, "end_fadein")
  database.load_route(save_id)
  get_tree().set_current_scene(get_node("/root/sector"))
