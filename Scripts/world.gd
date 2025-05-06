extends Node

@export var player_scene : PackedScene
@export var tile_scene : PackedScene

var player : CharacterBody2D
var tilemap : TileMap


func _ready():
	tilemap = get_node("TileMap")

func cuadros_alrededor(pos: Vector2i) -> void:
	for child in get_children():
		if child.name != "TileMap":  # Verifica si el nombre del nodo no es "TileMap"
			remove_child(child)
			child.queue_free()
		
	for i in range(-1, 2):
		for j in range(-1, 2):
			var offset = Vector2i(i, j)
			var cell = pos + offset
			var tile_id = tilemap.get_cell_source_id(0, cell)
			if tile_id != -1 and i != 0 or j != 0:
				var tile = tile_scene.instantiate()
				tile.position = tilemap.map_to_local(cell)
				add_child(tile)
#s
