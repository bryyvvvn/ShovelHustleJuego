extends Node

@export var player_scene : PackedScene
@export var tile_scene : PackedScene

var player : CharacterBody2D
var tilemap : TileMap
var pos_anterior = Vector2i(0,0)


func _ready():
	tilemap = get_node("TileMap")
	


func cuadros_alrededor(pos: Vector2i) -> void:
	
	for i in range(-1, 2):
		for j in range(-1, 2):
			var offset = Vector2i(i, j)
			var cell = pos_anterior + offset
			var tile_id = tilemap.get_cell_source_id(0, cell)
			if i!=0 or j != 0:
				tilemap.set_cell(0,cell,-1)
	
	for i in range(-1, 2):
		for j in range(-1, 2):
			var offset = Vector2i(i, j)
			var cell = pos + offset
			var tile_id = tilemap.get_cell_source_id(0, cell)
			if i!=0 or j != 0:
				tilemap.set_cell(0,cell, 0, Vector2(11,0),0)
	pos_anterior = pos
				
