extends Node

@export var grid_size := 10
@export var tile_scene : PackedScene
@export var player_scene: PackedScene
@export var tile_size := 32


var grid = []
var player

func borde_superior():
	var borde = StaticBody2D.new()
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	
	# Tamaño del borde
	shape.extents = Vector2(grid_size * tile_size / 2, tile_size / 2)
	col.shape = shape
	
	# Posición del borde
	borde.position = Vector2(grid_size * tile_size / 2, -tile_size / 2)
	
	borde.add_child(col)
	add_child(borde)
	

func cuadros_alrededor() -> Array:
	var player_tile_x = int(player.position.x / tile_size)
	var player_tile_y = int(player.position.y / tile_size)
	print(player_tile_x)
	var matriz = []
	var row = []
	
	for i in range(-1,2):
		row = []
		for j in range(-1,2):
			row.append([player_tile_x + i, player_tile_y + j])
		matriz.append(row)
	return matriz

	
func iniciar_mapa() -> void:	
	for i in range(grid_size):
		var row = []
		for j in range(grid_size):
			var tile = tile_scene.instantiate()
			tile.position = Vector2(i,j)*(tile_size)
			add_child(tile)
			row.append(tile)
		grid.append(row)
		
func iniciar_jugador() -> void:
	player = player_scene.instantiate()
	player.position = Vector2(1,1)*tile_size
	player.tile_size = tile_size
	add_child(player)

func _ready():
	iniciar_mapa()
	borde_superior()
	iniciar_jugador()
	
func _physics_process(delta: float) -> void:
	for fila in grid:
		for tile in fila:
			tile.set_flag(true)
	var alrededor = cuadros_alrededor()
	for i in range(3):
		for j in range(3):
			var nx = alrededor[i][j][0]
			var ny = alrededor[i][j][1]
			if nx >= 0 and nx < grid_size and ny >= 0 and ny < grid_size:
				grid[nx][ny].set_flag(false)
	
			
	
	

		
#row contiene tiles, tantos tiles como cuadros de arena tenga nuestro mapa
#cada uno de estos tiles en fila es una referencia a los atributos y caracteristicas en Tile.tscn
#add_child lo que hace es agregar cada tile como un nodo hijo del nodo raiz Node2D
#ademas el tile creado se ubica en la posicion que corresponde multiplicando el tamaño de cada tile
#por la posición donde deberia estar (vector(i,j)
