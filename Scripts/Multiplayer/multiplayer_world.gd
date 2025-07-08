extends Node2D

#ruidos para ubicar arboles, lagos y arreglar la forma del mapa
@export var noise_height_noise : NoiseTexture2D #forma de la isla
@export var noise_lakes_noise : NoiseTexture2D #ubicacion de los lagos
@export var noise_tree_text : NoiseTexture2D #ubicacion de los arboles

var noise : Noise
var noise_lakes : Noise
var tree_noise : Noise


#todas las capas del mapa
@onready var tilemap = $TileMap
@onready var sand_tile_map_layer := $TileMap/sand
@onready var sand_2_tile_map_layer := $TileMap/sand2
@onready var lakes_tile_map_layer := $TileMap/lakes
@onready var enviroment_tile_map_layer := $TileMap/enviroment
@onready var tiles_arround_tile_map_layer := $TileMap/bloques_alrededor
@onready var excavacion_tile_map_layer := $TileMap/excavacion

#Tamaño del mapa y ciclos para suavizar bordes del mapa
var map_width = 130
var map_height = 130
var smoothing_passes = 4


#arena, palmeras y decoraciones
var sand_elements = [Vector2i(1,4), Vector2i(5,4), Vector2i(13,4)]#arenas
var hole_elements = [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)]

var cactus_secos = [
	Vector2i(0, 1), Vector2i(2, 1), Vector2i(4, 1), Vector2i(6, 1), Vector2i(9, 1),
	Vector2i(13, 1), Vector2i(16, 1), Vector2i(19, 1), Vector2i(21, 1), Vector2i(23, 1),
	Vector2i(0, 4), Vector2i(2, 4), Vector2i(4, 3), Vector2i(6, 4), Vector2i(8, 4),
	Vector2i(15, 4), Vector2i(17, 4), Vector2i(19, 4), Vector2i(21, 4), Vector2i(23, 4)
]#cactus secos

var cactus_flores =[
	Vector2i(0, 13), Vector2i(2, 13), Vector2i(4, 13), Vector2i(6, 12), Vector2i(9, 12),
	Vector2i(13, 12), Vector2i(16, 12), Vector2i(18, 13), Vector2i(21, 13),
	Vector2i(0, 16), Vector2i(2, 16), Vector2i(4, 15), Vector2i(7, 16), Vector2i(9, 16),
	Vector2i(13, 16), Vector2i(16, 16), Vector2i(18, 15), Vector2i(21, 16), Vector2i(23, 16)
]#con flores

var cactus_verdes = [
	Vector2i(0, 19), Vector2i(2, 19), Vector2i(4, 19), Vector2i(6, 18), Vector2i(9, 18),
	Vector2i(13, 18), Vector2i(16, 18), Vector2i(19, 19), Vector2i(21, 19), Vector2i(23, 19),
	Vector2i(0, 22), Vector2i(2, 22), Vector2i(4, 22), Vector2i(6, 22), Vector2i(8, 22),
	Vector2i(15, 22), Vector2i(17, 22), Vector2i(19, 22), Vector2i(21, 22), Vector2i(23, 22)
]

var cactus_muy_verdes = [
	Vector2i(0, 25), Vector2i(2, 25), Vector2i(4, 25), Vector2i(6, 25), Vector2i(9, 25),
	Vector2i(13, 25), Vector2i(15, 25), Vector2i(17, 25), Vector2i(19, 25), Vector2i(22, 24),
	Vector2i(0, 28), Vector2i(2, 28), Vector2i(4, 28), Vector2i(6, 28), Vector2i(8, 28),
	Vector2i(13, 28), Vector2i(15, 28), Vector2i(17, 28), Vector2i(19, 28), Vector2i(21, 28)
]

#source de cada tileset
var atlas_id_arena = 0
var atlas_id_water1 = 1
var atlas_id_water2 = 2
var atlas_id_ground_staff = 3
var atlas_id_dessert_staff = 4
var atlas_id_bloques_alrededor = 6
var atlas_id_cactus = 5


#calcula la mitad del mapa
var map_mid_width = map_width / 2
var map_mid_height = map_height / 2

#array donde se almacenan la posicion de los tiles de agua y arena para generar el mundo
var mapa = [] # Matriz 2D: 0 = agua, 1 = arena

#posiciónes en las que no se puede cavar
var disabled_dig : Dictionary

#posicion anterior del jugador almacenada para ir borrando los tiles alrededor
var pos_anterior = Vector2i(0,0)

#diccionario que almacena el potenciador de cada posicion
var potentior : Dictionary
var multiplicador := 60
var brecha := 25

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
				tiles_arround_tile_map_layer.set_cell(cell, atlas_id_bloques_alrededor, Vector2(3,0))
	pos_anterior = pos


#marca el tile cavado
func bloque_cavado(cell: Vector2i) -> void:
	excavacion_tile_map_layer.set_cell(cell, atlas_id_bloques_alrededor, hole_elements.pick_random())
	disabled_dig[cell] = 0
	print(cell)


func enabled_dig(pos : Vector2i) -> bool:
	if disabled_dig.has(pos):
		return false
	return true
	


func get_potentior(pos: Vector2i) -> float:
	return potentior[pos]



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

			var max_dist = max(map_width, map_height) / 3
			var ruido = noise.get_noise_2d(gx, gy)
			var distancia = Vector2(gx + 50 * ruido, gy + 50 * ruido).length()
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
	var rich_zones = []
	for y in range(map_height):
		for x in range(map_width):
			var gx = x - map_mid_width
			var gy = y - map_mid_height
			var pos = Vector2i(gx, gy)
			
			var max_dist = min(map_width, map_height) / 2.0
			var dist_al_centro = Vector2(gx, gy).length()
			var mascara = 1.0 - (dist_al_centro / max_dist)
			
			var noise_lake_val = noise_lakes.get_noise_2d(gx, gy)
			var noise_tree_val = tree_noise.get_noise_2d(gx, gy)
			
			sand_tile_map_layer.set_cell(pos, atlas_id_arena, sand_elements.pick_random())
				
			if mapa[y][x] == 0:
				water_positions.append(pos)
				disabled_dig[pos] = 0
			else:
				# Árboles sobre arena
				if noise_tree_val < 0.8 and  noise_tree_val > 0.78 and noise_lake_val < 0.43 :
					disabled_dig[pos] = 0
					enviroment_tile_map_layer.set_cell(pos, atlas_id_cactus, cactus_muy_verdes.pick_random())

				if noise_lake_val > 0.39  and mascara > 0.4 and mascara < 0.9:
					disabled_dig[pos] = 0
					lake_positions.append(pos)
				
				if noise_lake_val > 0.33:
					sand_1_positions.append(pos)

	enviroment_tile_map_layer.set_cells_terrain_connect(water_positions, atlas_id_water1, 0)
	lakes_tile_map_layer.set_cells_terrain_connect(lake_positions, atlas_id_water2, 0)
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
