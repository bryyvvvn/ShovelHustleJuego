extends Node2D


@export var noise_height_noise : NoiseTexture2D
@export var noise_tree_text : NoiseTexture2D
@export var player_scene : PackedScene
@export var tile_scene : PackedScene

@onready var tilemap = $TileMap

#layers

var sand_layer = 0
var sand_1_layer = 1
var water_layer = 2
var enviroment_layer = 3
var bloques_alrededor_layer = 4
var excavacion_layer = 4

#var grass_elements = [Vector2i(1,0), Vector2i(3,0), Vector2i(4,0), Vector2i(5,0), Vector2i(0,0)] #pastos
#var grass_1_elements = [Vector2i(11,1), Vector2i(12,1), Vector2i(13,1), Vector2(14,1), Vector2(15,6)] #arboles
var sand_elements = [Vector2i(1,4), Vector2i(5,4), Vector2i(13,4)] #arenas
var sand_id = 0

var sand_1_elements = [Vector2i(9,1), Vector2i(11,1), Vector2i(9,3), Vector2i(11,3), Vector2(9,5), Vector2(11,5)]
var sand_2_elements = [Vector2i(1,3), Vector2i(2,3), Vector2i(3,5), Vector2i(0,5), Vector2(4,4), Vector2(5,1), Vector2(0,6)] #palmeras
var sand_1_id = 4


var noise : Noise
var tree_noise : Noise

var widht : int = 200
var height : int = 200

var source_id_arena = 0
var water_atlas = Vector2(0,1)
var land_atlas = Vector2(5,4)

var sand_tiles_arr = []
var terrain_sand_int = 0
#

var water_tiles_arr = []
var terrain_water_int = 1

var water_1_tiles_arr = []
var terrain_water_1_int = 2

var player : CharacterBody2D
var pos_anterior = Vector2i(0,0)
var noise_arr = []
var tree_noise_arr = []



func cuadros_alrededor(pos: Vector2i) -> void:
	
	for i in range(-1, 2):
		for j in range(-1, 2):
			var offset = Vector2i(i, j)
			var cell = pos_anterior + offset
			var tile_id = tilemap.get_cell_source_id(0, cell)
			if i!=0 or j != 0:
				tilemap.set_cell(bloques_alrededor_layer,cell,-1)
	
	for i in range(-1, 2):
		for j in range(-1, 2):
			var offset = Vector2i(i, j)
			var cell = pos + offset
			var tile_id = tilemap.get_cell_source_id(0, cell)
			if i!=0 or j != 0:
				tilemap.set_cell(bloques_alrededor_layer,cell, 5, Vector2(11,0),0)
	pos_anterior = pos


func bloque_cavado(cell: Vector2i) -> void:
	tilemap.set_cell(excavacion_layer,cell, 0, Vector2(13,0),0)
	print(cell)


func generate_world() -> void:
	var noise_val : float
	var tree_noise_value : float
	for x in range(-widht/2, widht/2):
		for y in range(-height/2, height/2):
			noise_val = noise.get_noise_2d(x,y)
			noise_arr.append(noise_val) # Usar porcentajes....
			
	for x in range(-widht/2, widht/2):
		for y in range(-height/2, height/2):
			noise_val = noise.get_noise_2d(x,y)
			tree_noise_value = tree_noise.get_noise_2d(x,y)
			tree_noise_arr.append(tree_noise_value)
			
			tilemap.set_cell(sand_layer, Vector2i(x,y), sand_id, sand_elements.pick_random())
				
				
			if  noise_val <= -0.2:
				water_tiles_arr.append(Vector2(x,y))
			
			if noise_val >=0.5:
				sand_tiles_arr.append(Vector2(x,y))
			
			if noise_val >= 0.6: 
				water_1_tiles_arr.append(Vector2(x,y))
			
				
				if noise_val > 0.02 and  tree_noise_value >= 0.8 and noise_val <= 0.12:
					pass
					#tilemap.set_cell(ground_2_layer, Vector2i(x,y), source_id, grass_1_elements.pick_random())
				if noise_val > 0.02 and noise_val <= 0.12:
					pass
					#tilemap.set_cell(ground_1_layer, Vector2i(x,y), source_id, grass_elements.pick_random())
					#tilemap.set_cell(ground_layer, clift_tiles_arr, terrain_clift_int, 0)
				if noise_val >= 0.12:
					sand_tiles_arr.append(Vector2(x,y))
					
			if noise_val >= -0.15 and noise_val <= 0.55 and  tree_noise_value >= 0.96:
				tilemap.set_cell(enviroment_layer, Vector2i(x,y), sand_1_id, sand_1_elements.pick_random())
				
			if noise_val >= -0.15 and noise_val <= 0.55 and  tree_noise_value >= 0.77 and tree_noise_value <= 0.8 :
				tilemap.set_cell(enviroment_layer, Vector2i(x,y), sand_1_id, sand_2_elements.pick_random())
			
			
	tilemap.set_cells_terrain_connect(water_layer, water_tiles_arr, terrain_water_int, 0)
	tilemap.set_cells_terrain_connect(water_layer, water_1_tiles_arr, terrain_water_1_int, 0)
	tilemap.set_cells_terrain_connect(sand_1_layer, sand_tiles_arr, terrain_sand_int, 0)
	#tilemap.set_cells_terrain_connect(ground_layer, sand_tiles_arr, terrain_sand_int, 0)
	print(noise_arr.min()) #pensar en si trabajar con maximos y minimos. porcentajes
	print(noise_arr.max())
	print(tree_noise_arr.min()) 
	print(tree_noise_arr.max())

func _ready() -> void:
	noise = noise_height_noise.noise
	noise.seed = randf() * 100
	tree_noise = noise_tree_text.noise
	
	generate_world()
