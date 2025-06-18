extends Node2D

@export var tile_map_scene : PackedScene
@export var player_scene : PackedScene
@export var shovel_scene : PackedScene
@export var objects_scene : PackedScene
@export var inventory_Scene : PackedScene
@export var tienda_scene : PackedScene
@export var inventory_inv : Inv
@export var tienda_ui_scene: PackedScene
@export var money_ref : Node


var player : CharacterBody2D
var tile_map
var shovel
var mouse_pos 
var inventory
var tienda
var tienda_ui

#energía en el juego
var energy := 100.0
var max_energy := 100.0

#tiempo en el juego
const total_seconds := 720.0  #12 minutos
const morning := 8.0  #comienza a las 8:00
var time_elapsed : float = 0.0
var day: int = 1
var max_days: int = 7
var cuota_diaria = 550
var day_ended = false

var mineral_sound : int

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
	var mineral : float = randf() * 100
	var tilemap = tile_map.get_node("TileMap")
	var mouse_pos = get_global_mouse_position()
	
	var basura : objectData = preload("res://Assets/Recursos/Objects/basura.tres")
	var tuberculo : objectData= preload("res://Assets/Recursos/Objects/tuberculo.tres")
	var piedra : objectData= preload("res://Assets/Recursos/Objects/piedra.tres")
	var carbon : objectData= preload("res://Assets/Recursos/Objects/carbon.tres")
	var hierro : objectData= preload("res://Assets/Recursos/Objects/hierro.tres")
	var plata : objectData= preload("res://Assets/Recursos/Objects/plata.tres")
	var oro : objectData= preload("res://Assets/Recursos/Objects/oro.tres")
	var diamante : objectData= preload("res://Assets/Recursos/Objects/diamante.tres")
	
	if mineral < basura.intervalo.x:
		return
	elif mineral < basura.intervalo.y and mineral > basura.intervalo.x:
		object.data = basura
		object.get_node("Sprite2D").texture = object.data.get_texture()
		mineral_sound = 0
		
	elif mineral > tuberculo.intervalo.x and mineral <= tuberculo.intervalo.y:
		object.data = tuberculo
		object.get_node("Sprite2D").texture = object.data.get_texture()
		mineral_sound = 1
		
	elif mineral > piedra.intervalo.x and mineral <= piedra.intervalo.y:
		object.data = piedra
		object.get_node("Sprite2D").texture = object.data.get_texture()
		mineral_sound = 2
		
	elif mineral > carbon.intervalo.x and mineral <= carbon.intervalo.y:
		object.data = carbon
		object.get_node("Sprite2D").texture = object.data.get_texture()
		mineral_sound = 3

	elif mineral > hierro.intervalo.x and mineral <= hierro.intervalo.y:
		object.data = hierro
		object.get_node("Sprite2D").texture = object.data.get_texture()
		mineral_sound = 4

	elif mineral > plata.intervalo.x and mineral <= plata.intervalo.y:
		object.data = plata
		object.get_node("Sprite2D").texture = object.data.get_texture()
		mineral_sound = 5

	elif mineral > oro.intervalo.x and mineral <= oro.intervalo.y :
		object.data = oro
		object.get_node("Sprite2D").texture = object.data.get_texture()
		mineral_sound = 6
	
	elif mineral > diamante.intervalo.x:
		print(diamante.intervalo.x)
		object.data = diamante
		object.get_node("Sprite2D").texture = object.data.get_texture()
		mineral_sound = 7
		
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
	get_node("mineral_sound").stream = object.data.sonido
	get_node("mineral_sound").play()

	# Reactivar collider cuando termine
	tween.finished.connect(func(): shape.disabled = false)


func init_world() -> void:
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
	var pala = preload("res://Assets/Recursos/Objects/pala.tres").duplicate()
	inventory = inventory_Scene.instantiate()
	$UI.add_child(inventory)
	
	var item = pala
	
	inventory_inv.insert(item)

func init_tienda_ui() -> void:
	tienda_ui = tienda_ui_scene.instantiate()
	$UI.add_child(tienda_ui)



	#var inv = Inv.new()
	#inventory.set_inventory(inv)  # Aquí lo conectas
	#inventory.inv.slots[0].item = pala
	#inventory.inv.slots[0].amount = 1
	#inventory.inv.update.emit()


@onready var trans = $UI/dayTransition
func _ready() -> void:
	
	init_world()
	init_player()
	init_shovel()
	init_tienda()
	init_tienda_ui()
	init_inventory()
	trans.connect("transition_done", Callable(self, "_on_transition_done"))
	
	Music.play_track(1)
	Music.start_random_music()

func _input(event):
	#para el menú de pausa
	if event.is_action_pressed("ui_cancel"):  # generalmente la tecla Esc
		if get_tree().paused:
			unpause_game()
		else:
			pause_game()
	
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
		if await shovel.cavar(mouse_pos, day):
			shovel.get_node("succesfull_dig").play()
			tile_map.bloque_cavado(mouse_pos)
			init_mineral()
			Vfx.play_mineral(mineral_sound)
		else:
			shovel.get_node("fail_dig").play()
			energy -= 8

func nextday(force : bool = false) -> void:
	var moni = player.money
	#if not player.is_in_bed or force:
		#player.money -= randi_range(10, 30)  # quitar dinero si no se acostó
		#victima_robo = true
	if force: 
		player.money -= randi_range(10,30)
	# transición de día
	var tiene_dinero = player.money >= cuota_diaria
	moni -= player.money
	trans.visible = true
	trans.setup(day, player.money, cuota_diaria, tiene_dinero, moni)
	day_ended = true
	
func _on_transition_done(success: bool):
	self.set_process(true)
	if success:
		day += 1
		time_elapsed = 0.0
		energy = max_energy
		player.money -= cuota_diaria
		cuota_diaria = cuota_diaria*1.8
		money_ref.set_bounty(cuota_diaria)
		day_ended = false
		
	else:
		get_tree().change_scene_to_file("res://Scenes/Menu/Menu.tscn")

func pause_game():
	get_tree().paused = true
	var pause_menu = preload("res://scenes/pause_menu.tscn").instantiate()
	pause_menu.name = "PauseMenu"
	add_child(pause_menu)

func unpause_game():
	get_tree().paused = false
	var existing = get_node_or_null("PauseMenu")
	if existing:
		existing.queue_free()
func _physics_process(delta: float) -> void:
	
	if day_ended:
		return
	
	var tile_pos = tile_map.get_node("TileMap").local_to_map(player.get_node("CollisionShape2D").global_position)
	tile_map.tiles_arround(tile_pos)
	
	energy -= 0.1389 * delta  #agota la energia en un periodo de 12 minutos
	$UI/energia.set_energy(energy / max_energy)
	
	if energy <= 0:
		nextday(true)  # perdido por agotamiento
		self.set_process(false)
	#if player.is_in_bed:
		
	
	#calcular tiempo segun delta
	time_elapsed += delta
	if time_elapsed >= total_seconds:
		nextday(true)
		self.set_process(false)
	var ratio : float = clamp(time_elapsed / total_seconds, 0.0, 1.0)
	var simulated_minutes: float = morning * 60 + ratio * (24 * 60 - morning * 60)
	var hours := int(simulated_minutes) / 60
	var minutes := int(simulated_minutes) % 60
	
	

	$UI/time/clockContainer/hora.text = "%02d:%02dHRS" % [hours, minutes]
	
	
	

	
	
	
	
	
