extends Node2D

@export var tile_map_scene : PackedScene
@export var player_scene : PackedScene
@export var shovel_scene : PackedScene
@export var objects_scene : PackedScene

var player : CharacterBody2D
var tile_map
var shovel
var mouse_pos 

#energía en el juego
var energy := 100.0
var max_energy := 100.0

#tiempo en el juego


func init_diamante()-> void:
	var object = objects_scene.instantiate()
	object.data = preload("res://Objects/diamante.tres")
	object.get_node("Sprite2D").texture = preload("res://Assets/Sprites/objects/diamante.png")
	
	add_child(object)


func init_world() -> void:
	tile_map = tile_map_scene.instantiate() 
	add_child(tile_map)

func init_player() -> void:
	player = player_scene.instantiate() 
	add_child(player)
	
func init_shovel()->void:
	shovel = shovel_scene.instantiate()
	add_child(shovel)

func _ready() -> void:
	init_world()
	init_player()
	init_shovel()
	init_diamante()


func _input(event):
	
	var tilemap = tile_map.get_node("TileMap")
	var pos = tilemap.local_to_map(player.get_node("CollisionShape2D").global_position)
	var posiciones = []
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in range(-1, 2):
			for j in range(-1, 2):
				var offset = Vector2i(i, j)
				var cell = pos + offset
				if i!=0 or j != 0 :
					posiciones.append(cell)
	
	if tilemap.local_to_map(get_global_mouse_position()) in posiciones and tile_map.enabled_dig(tilemap.local_to_map(get_global_mouse_position())):
		if await shovel.cavar(tilemap.local_to_map(get_global_mouse_position())):
			tile_map.bloque_cavado(tilemap.local_to_map(get_global_mouse_position()))
		else: 
			energy -= 8

func nextday(bool) -> void:
	print("fin de día")
	#algo pasará

func _physics_process(delta: float) -> void:
	
	var tile_pos = tile_map.get_node("TileMap").local_to_map(player.get_node("CollisionShape2D").global_position)
	tile_map.tiles_arround(tile_pos)
	
	energy -= 0.1389 * delta  #agota la energia en un periodo de 12 minutos
	$UI/energia.set_energy(energy / max_energy)
	
	if energy <= 0:
		nextday(true)  # perdido por agotamiento
	
	
	
	

	
	
	
	
	
