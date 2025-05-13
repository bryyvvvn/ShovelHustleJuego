extends Node2D

#ruidos para ubicar arboles, lagos y arreglar la forma del mapa
@export var noise_height_noise : NoiseTexture2D
@export var noise_lakes_noise : NoiseTexture2D
@export var noise_tree_text : NoiseTexture2D

var noise : Noise
var noise_lakes : Noise
var tree_noise : Noise


#todas las capas del mapa
@onready var tilemap = $TileMap
@onready var sand_tile_map_layer := $TileMap/sand
@onready var sand_2_tile_map_layer := $TileMap/sand2
@onready var water_tile_map_layer := $TileMap/water
@onready var enviroment_tile_map_layer := $TileMap/enviroment
@onready var tiles_arround_tile_map_layer := $TileMap/bloques_alrededor
@onready var excavacion_tile_map_layer := $TileMap/excavacion

#Tamaño del mapa y ciclos para suavizar bordes del mapa
var map_width = 500
var map_height = 500
var smoothing_passes = 5


#arena, palmeras y decoraciones
var sand_elements = [Vector2i(1,4), Vector2i(5,4), Vector2i(13,4)]#arenas
var sand_1_elements = [Vector2i(9,1), Vector2i(11,1), Vector2i(9,3), Vector2i(11,3), Vector2(9,5), Vector2(11,5)]#palmeras
var sand_2_elements = [Vector2i(1,3), Vector2i(2,3), Vector2i(3,5), Vector2i(0,5), Vector2(4,4), Vector2(5,1), Vector2(0,6)]#decoraciones

#source de cada tileset
var atlas_id_arena = 0
var atlas_id_water1 = 1
var atlas_id_water2 = 2
var atlas_id_ground_staff = 3
var atlas_id_dessert_staff = 4
var atlas_id_bloques_alrededor = 5

#calcula la mitad del mapa
var map_mid_width = map_width / 2
var map_mid_height = map_height / 2

#array donde se almacenan la posicion de los tiles de agua y arena para generar el mundo
var mapa = [] # Matriz 2D: 0 = agua, 1 = arena

#posiciónes en las que no se puede cavar
var disabled_dig : Dictionary

#posicion anterior del jugador almacenada para ir borrando los tiles alrededor
var pos_anterior = Vector2i(0,0)

#funcion para pintar los tiles alrededor del jugador
func tiles_arround(pos: Vector2i) -> void:
	for i in range(-1, 2):
		for j in range(-1, 2):
			var offset = Vector2i(i, j)
			var cell = pos_anterior + offset
			if i != 0 or j != 0:
				tiles_arround_tile_map_layer.set_cell(cell, -1)
	for i in range(-1, 2):
		for j in range(-1, 2):
			var offset = Vector2i(i, j)
			var cell = pos + offset
			if i != 0 or j != 0:
				tiles_arround_tile_map_layer.set_cell(cell, atlas_id_bloques_alrededor, Vector2(11,0))
	pos_anterior = pos


#marca el tile cavado
func bloque_cavado(cell: Vector2i) -> void:
	excavacion_tile_map_layer.set_cell(cell, atlas_id_bloques_alrededor, Vector2(13,0))
	disabled_dig[cell] = 0
	print(cell)


func enabled_dig(pos : Vector2i) -> bool:
	if disabled_dig.has(pos):
		return false
	return true

#funcion para generar mapa base
func generar_mapa_base():
	mapa.resize(map_height)
	for y in range(map_height):
		mapa[y] = []
		for x in range(map_width):
			var gx = x - map_mid_width
			var gy = y - map_mid_height

			if x == 0 or y == 0 or x == map_width - 1 or y == map_height - 1:
				mapa[y].append(0)
				continue

			var max_dist = max(map_width, map_height) / 2.0
			var ruido = noise.get_noise_2d(gx, gy)
			var distancia = Vector2(gx + 120 * ruido, gy + 120 * ruido).length()
			var prob = 1.0 - (distancia / (max_dist * 0.7))

			if randf() < prob:
				mapa[y].append(1)
			else:
				mapa[y].append(0)


#funcion para suavizar los bordes
func suavizar():
	var nueva = []
	nueva.resize(map_height)
	for y in range(map_height):
		nueva[y] = []
		for x in range(map_width):
			if x == 0 or y == 0 or x == map_width - 1 or y == map_height - 1:
				nueva[y].append(0)
				continue
			var arena_cercana = contar_vecinos(x, y)
			if arena_cercana >= 2:
				nueva[y].append(1)
			else:
				nueva[y].append(0)
	mapa = nueva


#funcion para contar los vecinos de cada tile y ver si son arena o agua.
func contar_vecinos(x: int, y: int) -> int:
	var conteo = 0
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and ny >= 0 and nx < map_width and ny < map_height:
				if mapa[ny][nx] == 1:
					conteo += 1
	return conteo


#finalmente se genera el mapa final, con suavizacion y todo
func aplicar_mapa():
	var water_positions = []
	var lake_positions = []
	var sand_1_positions = []
	for y in range(map_height):
		for x in range(map_width):
			var gx = x - map_mid_width
			var gy = y - map_mid_height
			var pos = Vector2i(gx, gy)
			
			var noise_lake_val = noise_lakes.get_noise_2d(gx, gy)
			var noise_tree_val = tree_noise.get_noise_2d(gx, gy)
			
			sand_tile_map_layer.set_cell(pos, atlas_id_arena, sand_elements.pick_random())
			
			if mapa[y][x] == 0:
				water_positions.append(pos)
				disabled_dig[pos] = 0
			else:
				# Árboles sobre arena
				if noise_tree_val < 0.8 and  noise_tree_val > 0.7 and noise_lake_val < 0.43 :
					disabled_dig[pos] = 0
					enviroment_tile_map_layer.set_cell(pos, atlas_id_dessert_staff, sand_2_elements.pick_random())
					
				if noise_tree_val > 0.9  and noise_lake_val < 0.43 :
					disabled_dig[pos] = 0
					enviroment_tile_map_layer.set_cell(pos, atlas_id_dessert_staff, sand_1_elements.pick_random())
				
				# Lagos internos
				var max_dist = min(map_width, map_height) / 2.0
				var dist_al_centro = Vector2(gx, gy).length()
				var mascara = 1.0 - (dist_al_centro / max_dist)

				if noise_lake_val > 0.43  and mascara > 0.4:
					disabled_dig[pos] = 0
					lake_positions.append(pos)
				
				if noise_lake_val > 0.33:
					sand_1_positions.append(pos)

	water_tile_map_layer.set_cells_terrain_connect(water_positions, atlas_id_water1, 0)
	water_tile_map_layer.set_cells_terrain_connect(lake_positions, atlas_id_water2, 0)
	sand_2_tile_map_layer.set_cells_terrain_connect(sand_1_positions, atlas_id_arena, 0)
	
	
func _ready():
	randomize()
	noise = noise_height_noise.noise
	noise.seed = randi()
	noise_lakes = noise_lakes_noise.noise
	noise_lakes.seed = randi()
	tree_noise = noise_tree_text.noise
	tree_noise.seed = randi()

	generar_mapa_base()
	for i in range(smoothing_passes):
		suavizar()
	aplicar_mapa()
