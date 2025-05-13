extends Node2D

@export var tile_map_scene : PackedScene
@export var player_scene : PackedScene
@export var shovel_scene : PackedScene
@export var objects_scene : PackedScene

var player : CharacterBody2D
var tile_map
var shovel
var mouse_pos 

#energía en el juego
var energy := 100.0
var max_energy := 100.0

#tiempo en el juego
var time := 0.0

#entre 0 y 0.35 -> nada
var nada : float = 0.35
#entre 0.35 y 0.6 -> piedra
var piedra : float = 0.6
#entre 0.6 y 0.75 -> carbon
var carbon : float = 0.75
#entre 0.75 y 0.85 -> hierro
var hierro : float = 0.85
#entre 0.85 y 0.925 -> plata
var plata : float = 0.925
#entre 0.925 y 0.975 -> oro
var oro : float = 0.975
#mayor a 0.975 -> diamante

	
	
func init_mineral() -> void:
	randomize()
	var object = objects_scene.instantiate()
	var mineral : float = randf()
	var tilemap = tile_map.get_node("TileMap")
	var mouse_pos = get_global_mouse_position()
	var dir_x : int
	var dir_y : int
	
	if randf() < 0.5: dir_x = -1
	else: dir_x = 1
	if randf() < 0.5: dir_y = -1
	else: dir_y = 1
	
	if mineral < nada:
		pass
	elif mineral > nada and mineral <= piedra:
		object.data = preload("res://Objects/piedra.tres")
		object.get_node("Sprite2D").texture = preload("res://Assets/Sprites/objects/piedra.png")
	elif mineral > piedra and mineral <= carbon:
		object.data = preload("res://Objects/carbon.tres")
		object.get_node("Sprite2D").texture = preload("res://Assets/Sprites/objects/carbon.png")
	elif mineral > carbon and mineral <= hierro:
		object.data = preload("res://Objects/hierro.tres")
		object.get_node("Sprite2D").texture = preload("res://Assets/Sprites/objects/hierro.png")
	elif mineral > hierro and mineral <= plata:
		object.data = preload("res://Objects/plata.tres")
		object.get_node("Sprite2D").texture = preload("res://Assets/Sprites/objects/plata.png")
	elif mineral > plata and mineral <= oro:
		object.data = preload("res://Objects/oro.tres")
		object.get_node("Sprite2D").texture = preload("res://Assets/Sprites/objects/oro.png")
	elif mineral > oro:
		object.data = preload("res://Objects/diamante.tres")
		object.get_node("Sprite2D").texture = preload("res://Assets/Sprites/objects/diamante.png")

		
	var dir = Vector2(dir_x,dir_y)  # o cualquier dirección (arriba, abajo, etc.)
	var end_pos = mouse_pos - dir*16

	add_child(object)
	object.global_position = mouse_pos

	var tween = create_tween()
	var altura_max = -50.0  # altura del salto en píxeles (negativo porque Y crece hacia abajo)

	tween.tween_method(
		func(t): 
			var t1 = t
			var x = lerp(mouse_pos.x, end_pos.x, t1)
			var y = lerp(mouse_pos.y, end_pos.y, t1) + sin(t1 * PI) * altura_max
			object.global_position = Vector2(x, y),
		0.0, 1.0, 0.4
	)

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
				if i!=0 or j != 0 :
					posiciones.append(cell)
	
	var mouse_pos = tilemap.local_to_map(get_global_mouse_position())
	if mouse_pos in posiciones and tile_map.enabled_dig(mouse_pos):
		if await shovel.cavar(mouse_pos):
			tile_map.bloque_cavado(mouse_pos)
			init_mineral()
		else:
			energy -= 8

func nextday(bool) -> void:
	print("fin de día")
	#algo pasará

func _physics_process(delta: float) -> void:
	
	var tile_pos = tile_map.get_node("TileMap").local_to_map(player.get_node("CollisionShape2D").global_position)
	tile_map.tiles_arround(tile_pos)
	
	energy -= 0.1389 * delta  #agota la energia en un periodo de 12 minutos
	$UI/energia.set_energy(energy / max_energy)
	
	if energy <= 0:
		nextday(true)  # perdido por agotamiento
	
	
	
	
	

	
	
	
	
	
