extends Node2D

@export var noise_height_noise : NoiseTexture2D
@export var noise_lakes_noise : NoiseTexture2D
@export var noise_tree_text : NoiseTexture2D
@export var player_scene : PackedScene
@export var tile_scene : PackedScene

@onready var tilemap = $TileMap
@onready var sand_tile_map_layer := $TileMap/sand
@onready var sand_2_tile_map_layer := $TileMap/sand2
@onready var water_tile_map_layer := $TileMap/water
@onready var enviroment_tile_map_layer := $TileMap/enviroment
@onready var tiles_arround_tile_map_layer := $TileMap/bloques_alrededor

var map_width = 500
var map_height = 500
var smoothing_passes = 5

var sand_elements = [Vector2i(1,4), Vector2i(5,4), Vector2i(13,4)]
var sand_1_elements = [Vector2i(9,1), Vector2i(11,1), Vector2i(9,3), Vector2i(11,3), Vector2(9,5), Vector2(11,5)]
var sand_2_elements = [Vector2i(1,3), Vector2i(2,3), Vector2i(3,5), Vector2i(0,5), Vector2(4,4), Vector2(5,1), Vector2(0,6)]

var atlas_id_arena = 0
var atlas_id_water1 = 1
var atlas_id_water2 = 2
var atlas_id_ground_staff = 3
var atlas_id_dessert_staff = 4
var atlas_id_bloques_alrededor = 5

var terrain_sand_int = 0
var terrain_water_int = 1
var terrain_water_1_int = 2

var map_mid_width = map_width / 2
var map_mid_height = map_height / 2

var mapa = [] # Matriz 2D: 0 = agua, 1 = arena

var noise : Noise
var noise_lakes : Noise
var tree_noise : Noise

var player : CharacterBody2D
var pos_anterior = Vector2i(0,0)

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
				tiles_arround_tile_map_layer.set_cell(cell, 5, Vector2(11,0), 0)
	pos_anterior = pos

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
			else:
				# Árboles sobre arena
				if noise_tree_val < 0.8 and  noise_tree_val > 0.7 and noise_lake_val < 0.43 :
					enviroment_tile_map_layer.set_cell(pos, atlas_id_dessert_staff, sand_2_elements.pick_random())
					
				if noise_tree_val > 0.9  and noise_lake_val < 0.43 :
					enviroment_tile_map_layer.set_cell(pos, atlas_id_dessert_staff, sand_1_elements.pick_random())
				
				# Lagos internos
				var max_dist = min(map_width, map_height) / 2.0
				var dist_al_centro = Vector2(gx, gy).length()
				var mascara = 1.0 - (dist_al_centro / max_dist)

				if noise_lake_val > 0.43  and mascara > 0.4:
					lake_positions.append(pos)
				
				if noise_lake_val > 0.33:
					sand_1_positions.append(pos)

	water_tile_map_layer.set_cells_terrain_connect(water_positions, terrain_water_int, 0)
	water_tile_map_layer.set_cells_terrain_connect(lake_positions, terrain_water_1_int, 0)
	sand_2_tile_map_layer.set_cells_terrain_connect(sand_1_positions, terrain_sand_int, 0)
