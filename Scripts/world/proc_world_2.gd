extends Node2D
##Cuando se genere el mapa procedural, hay que acceder al diccionario e 
##inhabilitar para excavacion todos los tiles correspondientes por ejemplo 
##el agua, los arboles etc.

@export var noise_height_noise : NoiseTexture2D
@export var noise_tree_text : NoiseTexture2D
@export var player_scene : PackedScene
@export var tile_scene : PackedScene

@onready var tilemap = $TileMap
@onready var sand_tile_map_layer := $TileMap/sand #arena base
@onready var sand_2_tile_map_layer := $TileMap/sand2 #arena de orilla
@onready var water_tile_map_layer := $TileMap/water #agua en general
@onready var enviroment_tile_map_layer := $TileMap/enviroment #decoraciones
@onready var tiles_arround_tile_map_layer := $TileMap/bloques_alrededor #bloques alrededor






#var grass_elements = [Vector2i(1,0), Vector2i(3,0), Vector2i(4,0), Vector2i(5,0), Vector2i(0,0)] #pastos
#var grass_1_elements = [Vector2i(11,1), Vector2i(12,1), Vector2i(13,1), Vector2(14,1), Vector2(15,6)] #arboles
var sand_elements = [Vector2i(1,4), Vector2i(5,4), Vector2i(13,4)] #arenas


var sand_1_elements = [Vector2i(9,1), Vector2i(11,1), Vector2i(9,3), Vector2i(11,3), Vector2(9,5), Vector2(11,5)]
var sand_2_elements = [Vector2i(1,3), Vector2i(2,3), Vector2i(3,5), Vector2i(0,5), Vector2(4,4), Vector2(5,1), Vector2(0,6)] #palmeras

##Tamaño mapa procedural
var widht : int = 400
var height : int = 400


##id de los atlas
var atlas_id_arena = 0
var atlas_id_water1 = 1
var atlas_id_water2 = 2
var atlas_id_ground_staff = 3
var atlas_id_dessert_staff = 4
var atlas_id_bloques_alrededor = 5


##array con ubicaciones y terrenos correespondientes
var sand_tiles_arr = [] ##arena costera
var terrain_sand_int = 0

var water_tiles_arr = [] ##agua profunda
var terrain_water_int = 1

var water_1_tiles_arr = [] ##agua no profunda
var terrain_water_1_int = 2


##variables para los bloques alrededor del jugador
var player : CharacterBody2D
var pos_anterior = Vector2i(0,0)


##ruidos para ubicar: arena costera, agua progunda y agua no profunda
var noise : Noise
var noise_arr = []
##ruido para ubicar enviroment
var tree_noise : Noise
var tree_noise_arr = []


##funcion para reconocer y pintar bloques alrededor del jugador
func tiles_arround(pos: Vector2i) -> void:
	
	for i in range(-1, 2):
		for j in range(-1, 2):
			var offset = Vector2i(i, j)
			var cell = pos_anterior + offset
			var tile_id = tilemap.get_cell_source_id(0, cell)
			if i!=0 or j != 0:
				tiles_arround_tile_map_layer.set_cell(cell,-1)
	
	for i in range(-1, 2):
		for j in range(-1, 2):
			var offset = Vector2i(i, j)
			var cell = pos + offset
			var tile_id = tilemap.get_cell_source_id(0, cell)
			if i!=0 or j != 0:
				tiles_arround_tile_map_layer.set_cell(cell, 5, Vector2(11,0),0)
	pos_anterior = pos


##funcion para reconocer y pintar bloque cavado (arreglar aun)
func bloque_cavado(cell: Vector2i) -> void:
	##tilemap.set_cell(cell, 0, Vector2(13,0),0)
	print(cell)


##generacion del mundo
func generate_world() -> void:
	
	var noise_val : float
	var tree_noise_value : float
	
	for x in range(-widht/2, widht/2):
		for y in range(-height/2, height/2):
			noise_val = noise.get_noise_2d(x,y)
			noise_arr.append(noise_val) # Usar porcentajes....
			tree_noise_value = tree_noise.get_noise_2d(x,y)
			tree_noise_arr.append(tree_noise_value)
			
	var min_noise_val = abs(noise_arr.min())
	var min_noise_tree_val = abs(tree_noise_arr.min())
	
	var max_noise_val = abs(noise_arr.max())
	var max_noise_tree_val = abs(tree_noise_arr.max())
			
			
	for x in range(-widht/2, widht/2):
		for y in range(-height/2, height/2):
			noise_val = noise.get_noise_2d(x,y)
			tree_noise_value = tree_noise.get_noise_2d(x,y)
			
			sand_tile_map_layer.set_cell(Vector2i(x,y), atlas_id_arena, sand_elements.pick_random())
				
				
			if  noise_val <= -0.7*min_noise_val :
				water_tiles_arr.append(Vector2(x,y))
			
			if noise_val >= 0.7*max_noise_val :
				sand_tiles_arr.append(Vector2(x,y))
			
			if noise_val >= 0.8*max_noise_val: 
				water_1_tiles_arr.append(Vector2(x,y))
			
			if noise_val > 0.6*min_noise_val and noise_val < 0.78*max_noise_val and  tree_noise_value >= 0.97*max_noise_tree_val:
				enviroment_tile_map_layer.set_cell(Vector2i(x,y), atlas_id_dessert_staff, sand_1_elements.pick_random())
				
			if noise_val > -0.71*min_noise_val and noise_val < 0.59*max_noise_val and  tree_noise_value >= 0.79*max_noise_tree_val and tree_noise_value <= 0.8*max_noise_tree_val :
				enviroment_tile_map_layer.set_cell(Vector2i(x,y), atlas_id_dessert_staff, sand_2_elements.pick_random())
			
			
	water_tile_map_layer.set_cells_terrain_connect(water_tiles_arr, terrain_water_int, 0)
	water_tile_map_layer.set_cells_terrain_connect(water_1_tiles_arr, terrain_water_1_int, 0)
	sand_2_tile_map_layer.set_cells_terrain_connect(sand_tiles_arr, terrain_sand_int, 0)
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
