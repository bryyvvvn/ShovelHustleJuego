extends Node2D

@export var tile_map_scene : PackedScene
@export var player_scene : PackedScene
@export var shovel_scene : PackedScene
@export var objects_scene : PackedScene
@export var inventory_Scene : PackedScene
@export var tienda_scene : PackedScene
@export var inventory_inv : Inv


var player : CharacterBody2D
var tile_map
var shovel
var mouse_pos 
var inventory
var tienda

#energía en el juego
var energy := 100.0
var max_energy := 100.0

#tiempo en el juego
const total_seconds := 720.0  #12 minutos
const morning := 8.0  #comienza a las 8:00
var time_elapsed : float = 0.0
var day: int = 1
var max_days: int = 7
var day_ended: bool = false

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

func init_tienda()-> void:
	randomize()
	var angulo = deg_to_rad(randi() % 361) ## el resto de una division siempre sera un numero entre 0 y el divisor
	var modulo = 320
	var tienda_pos = Vector2(int(320*cos(angulo)), int(320*sin(angulo)))
	
	tienda = tienda_scene.instantiate()
	tienda.position = tienda_pos
	add_child(tienda)
	
	
func init_mineral() -> void:
	randomize()
	var object = objects_scene.instantiate()
	var mineral : float = randf()
	var tilemap = tile_map.get_node("TileMap")
	var mouse_pos = get_global_mouse_position()
	
	if mineral < nada:
		object.data = preload("res://Objects/basura.tres")
		object.get_node("Sprite2D").texture = object.data.get_texture()
		
	elif mineral > nada and mineral <= piedra:
		object.data = preload("res://Objects/piedra.tres")
		object.get_node("Sprite2D").texture = object.data.get_texture()
		
	elif mineral > piedra and mineral <= carbon:
		object.data = preload("res://Objects/carbon.tres")
		object.get_node("Sprite2D").texture = object.data.get_texture()
		
	elif mineral > carbon and mineral <= hierro:
		object.data = preload("res://Objects/hierro.tres")
		object.get_node("Sprite2D").texture = object.data.get_texture()

	elif mineral > hierro and mineral <= plata:
		object.data = preload("res://Objects/plata.tres")
		object.get_node("Sprite2D").texture = object.data.get_texture()

	elif mineral > plata and mineral <= oro:
		object.data = preload("res://Objects/oro.tres")
		object.get_node("Sprite2D").texture = object.data.get_texture()

	elif mineral > oro:
		object.data = preload("res://Objects/diamante.tres")
		object.get_node("Sprite2D").texture = object.data.get_texture()
		
	var angulo = deg_to_rad(randi() % 361)
	var dir = Vector2(cos(angulo),sin(angulo))  # o cualquier dirección (arriba, abajo, etc.)
	var end_pos = mouse_pos - dir*25

	add_child(object)
	object.get_node("CollisionShape2D").disabled = true
	
	var shape = object.get_node("CollisionShape2D")
	shape.disabled = true
	object.global_position = mouse_pos

	var tween = create_tween()
	var altura_max = -30.0

	tween.tween_method(
		func(t): 
			var x = lerp(mouse_pos.x, end_pos.x, t)
			var y = lerp(mouse_pos.y, end_pos.y, t) + sin(t * PI) * altura_max
			object.global_position = Vector2(x, y),
		0.0, 1.0, 0.4
	)

	# Reactivar collider cuando termine
	tween.finished.connect(func(): shape.disabled = false)


func init_world() -> void:
	print("entre aca")
	tile_map = tile_map_scene.instantiate() 
	add_child(tile_map)


func init_player() -> void:
	player = player_scene.instantiate() 
	add_child(player)
	$UI/money/Panel/moneylabel.player_ref = player


func init_shovel()->void:
	shovel = shovel_scene.instantiate()
	add_child(shovel)


func init_inventory() -> void:
	var pala = preload("res://Objects/pala.tres").duplicate()
	inventory = inventory_Scene.instantiate()
	$UI.add_child(inventory)
	
	var item = pala
	
	inventory_inv.insert(item)



	#var inv = Inv.new()
	#inventory.set_inventory(inv)  # Aquí lo conectas
	#inventory.inv.slots[0].item = pala
	#inventory.inv.slots[0].amount = 1
	#inventory.inv.update.emit()



func _ready() -> void:
	init_world()
	init_player()
	init_shovel()
	init_inventory()
	init_tienda()


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

func nextday(force : bool = false) -> void:
	day_ended = true

	#if not player.is_in_bed or force:
		#player.money -= randi_range(10, 30)  # quitar dinero si no se acostó
	if force: 
		player.money -= randi_range(10,30)
	# transición de día
	#var transition = preload("res://scenes/DayTransition.tscn").instantiate()
	#transition.setup(day, player.money, cuota_diaria, player.money >= cuota_diaria)
	#$UI.add_child(transition)

func _physics_process(delta: float) -> void:
	
	var tile_pos = tile_map.get_node("TileMap").local_to_map(player.get_node("CollisionShape2D").global_position)
	tile_map.tiles_arround(tile_pos)
	
	energy -= 0.1389 * delta  #agota la energia en un periodo de 12 minutos
	$UI/energia.set_energy(energy / max_energy)
	
	if energy <= 0:
		nextday(true)  # perdido por agotamiento
	
	if day_ended:
		return
	#calcular tiempo segun delta
	time_elapsed += delta
	if time_elapsed >= total_seconds:
		nextday(true)
	var ratio : float = clamp(time_elapsed / total_seconds, 0.0, 1.0)
	var simulated_minutes: float = morning * 60 + ratio * (24 * 60 - morning * 60)
	var hours := int(simulated_minutes) / 60
	var minutes := int(simulated_minutes) % 60

	$UI/time/clockContainer/hora.text = "%02d:%02dHRS" % [hours, minutes]
	
	
	

	
	
	
	
	
