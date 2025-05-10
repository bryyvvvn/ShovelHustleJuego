extends Node2D

@export var tile_map_scene : PackedScene
@export var player_scene : PackedScene
@export var shovel_scene : PackedScene

var player : CharacterBody2D
var tile_map
var shovel
var mouse_pos 



#func init_animations()-> void:
	#Animations.instanciar_animaciones(1, tile_map.get_node("TileMap").tile_set)
	#Animations.instanciar_animaciones(1)


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
	#init_animations()
	init_player()
	init_shovel()


func _input(event):
	
	var tilemap = tile_map.get_node("TileMap")
	var pos = tilemap.local_to_map(player.get_node("CollisionShape2D").global_position)
	var posiciones = []
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in range(-1, 2):
			for j in range(-1, 2):
				var offset = Vector2i(i, j)
				var cell = pos + offset
				if i!=0 or j != 0:
					posiciones.append(cell)
	
	if tilemap.local_to_map(get_global_mouse_position()) in posiciones:
		shovel.cavar(tilemap.local_to_map(get_global_mouse_position()))
		tile_map.bloque_cavado(tilemap.local_to_map(get_global_mouse_position()))

func _physics_process(delta: float) -> void:
	var tile_pos = tile_map.get_node("TileMap").local_to_map(player.get_node("CollisionShape2D").global_position)
	tile_map.cuadros_alrededor(tile_pos)
	
	
	

	
	
	
	
	
