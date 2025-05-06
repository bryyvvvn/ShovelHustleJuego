extends Node2D

@export var tile_map_scene : PackedScene
@export var player_scene : PackedScene

var player : CharacterBody2D
var tile_map

func init_world() -> void:
	# Instanciar el TileMap y agregarlo como hijo del nodo actual
	tile_map = tile_map_scene.instantiate() 
	add_child(tile_map)

func init_player() -> void:
	# Instanciar y agregar al jugador
	player = player_scene.instantiate() 
	add_child(player)


func _ready() -> void:
	init_world()
	init_player()

func _physics_process(delta: float) -> void:
	var tile_pos = tile_map.get_node("TileMap").local_to_map(player.get_node("CollisionShape2D").global_position)
	tile_map.cuadros_alrededor(tile_pos)
	
	
