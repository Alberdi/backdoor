
extends Node

# Scenes
const RouteScene = preload("res://model/route.tscn")

# Classes
const Identifiable = preload("res://model/identifiable.gd")
const Body         = preload("res://model/body.gd")
const Actor        = preload("res://model/actor.gd")
const Map          = preload("res://scenes/map.gd")

var current_sector
var player
var id

static func get_player_name_from_file(file):
	# Open file
	var data = {}
	# Parse to json
	var text = file.get_as_text()
	data.parse_json(text)
	file.close()
	var sector_data
	for sector in data["sectors"]:
		if sector["id"] == data["current_sector"]:
			sector_data = sector
	return sector_data["actors"][int(data["player_actor_id"])]["name"]

static func load_from_file(id, file, root):
	var route = RouteScene.instance()
	route.id = id
	# Open file
	var data = {}
	# Parse to json
	var text = file.get_as_text()
	data.parse_json(text)
	var sectors = data["sectors"]
	for sector_data in sectors:
		route.get_node("sectors").add_child(Map.unserialize(sector_data, root))
	# Set current sector
	route.current_sector = route.find_sector(data["current_sector"])
	route.current_sector.show()
	# Store reference to player
	route.player = route.current_sector.get_node("actors").get_child(data["player_actor_id"])
	var player_body = route.current_sector.get_actor_body(route.player)
	route.current_sector.find_body_view(player_body).highlight()
	return route

func save_to_file(file):
	var data = {}
	data["sectors"] = []
	data["current_sector"] = current_sector.id
	# Group sectors into a single array
	var sectors = [current_sector]
	for sector in get_node("sectors").get_children():
		sectors.append(sector)
	var sectors_data = []
	var player_actor_id = -1
	data["sectors"] = sectors_data
	# Serialize sectors
	for sector in sectors:
		var sector_data = sector.serialize()
		sectors_data.append(sector_data)
		var i = 0
		for actor_data in sector_data["actors"]:
			if actor_data["name"] == player.char_name:
				player_actor_id = i
				break
			i += 1
	data["player_actor_id"] = player_actor_id
	file.store_string(data.to_json())

func _init():
	print("route created")

func _ready():
	open_current_sector(null)
	print("route ready")

func find_sector(id):
	for sector in get_node("sectors").get_children():
		if sector.id == id:
			return sector
	if current_sector.id == id:
		return current_sector
	return null

func change_sector(target):
	var player_body = current_sector.get_actor_body(player)
	close_current_sector()
	get_node("sectors").add_child(current_sector)
	current_sector = find_sector(target)
	open_current_sector(player_body)

func close_current_sector():
	current_sector.set_fixed_process(false)
	current_sector.hide()
	current_sector.remove_actor(player)
	get_node("/root/sector").close()

func open_current_sector(player_body):
	var sector = get_node("/root/sector")
	get_node("sectors").remove_child(current_sector)
	sector.add_child(current_sector)
	sector.move_child(current_sector, 0)
	current_sector.set_name("map")
	current_sector.set_fixed_process(true)
	current_sector.show()
	# Set up camera
	current_sector.attach_camera(player)
	if player_body != null:
		current_sector.add_body(player_body)
		current_sector.add_actor(player_body, player)
		current_sector.move_actor(player, Vector2(0,0))
	sector.new_sector()