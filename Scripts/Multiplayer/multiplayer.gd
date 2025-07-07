extends Node2D

@export var tile_map_scene : PackedScene
@export var player_scene : PackedScene
@export var shovel_scene : PackedScene
@export var objects_scene : PackedScene
@export var inventory_Scene : PackedScene
@export var tienda_ui_scene: PackedScene
@export var inventory_inv : Inv
@export var money_ref : Node


#online interactions:
@onready var online = $online


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
var time_elapsed : float = 0.0
var day: int = 1
var max_days: int = 7
var cuota_diaria = 550
var day_ended = false
var mineral_sound : int

var basura : objectData = preload("res://Assets/Recursos/Objects/basura.tres")
var tuberculo : objectData= preload("res://Assets/Recursos/Objects/tuberculo.tres")
var piedra : objectData= preload("res://Assets/Recursos/Objects/piedra.tres")
var carbon : objectData= preload("res://Assets/Recursos/Objects/carbon.tres")
var hierro : objectData= preload("res://Assets/Recursos/Objects/hierro.tres")
var plata : objectData= preload("res://Assets/Recursos/Objects/plata.tres")
var oro : objectData= preload("res://Assets/Recursos/Objects/oro.tres")
var diamante : objectData= preload("res://Assets/Recursos/Objects/diamante.tres")
var nada : objectData= preload("res://Assets/Recursos/Objects/nada.tres")






func init_mineral() -> void:
	randomize()
	var object = objects_scene.instantiate()
	var mineral : float = (randf() * 100)
	var tilemap = tile_map.get_node("TileMap")
	var mouse_pos = get_global_mouse_position()
	
	
	var minerales = [ nada, basura, tuberculo, piedra, carbon, hierro, plata, oro, diamante]
	
	for entry in minerales:
		var intervalo = entry.intervalo
		if mineral > intervalo.x and mineral <= intervalo.y:
			object.data = entry
			object.get_node("Sprite2D").texture = entry.get_texture()
			break
			
	if object.data.nombre == "nada":
		return
		
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
		get_node("UI"). get_node("Tienda_o_Ui").enabled = true;

@onready var trans = $UI/dayTransition
func _ready() -> void:
	$"AudioStreamPlayer2D"
	$"AudioStreamPlayer2D".play()
	init_world()
	init_player()
	player.enable_to_open = true
	init_shovel()
	init_inventory()
	init_tienda_ui()
	var object = objects_scene.instantiate()
	object.data = preload("res://Assets/Recursos/Objects/tuberculo.tres")
	add_child(object)
	
	trans.connect("transition_done", Callable(self, "_on_transition_done"))

func _input(event):
	#para el menú de pausa
	if event.is_action_pressed("ui_cancel"):  # generalmente la tecla Esc
		var existing = get_node_or_null("PauseMenu")
		if existing:
			existing.queue_free()
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
		else:
			shovel.get_node("fail_dig").play()
			energy -= 8




func pause_game():
	var pause_menu = preload("res://scenes/Menu/in_game_menu.tscn").instantiate()
	pause_menu.name = "PauseMenu"
	add_child(pause_menu)



func unpause_game():
	var existing = get_node_or_null("PauseMenu")
	if existing:
		existing.queue_free()





func _physics_process(delta: float) -> void:
	
	var tile_pos = tile_map.get_node("TileMap").local_to_map(player.get_node("CollisionShape2D").global_position)
	tile_map.tiles_arround(tile_pos)
	
	energy -= 0.1389 * delta  #agota la energia en un periodo de 12 minutos
	$UI/energia.set_energy(energy / max_energy)
	
	if energy <= 0:
		online.sendDefeat()
	
	time_elapsed += delta
	
	var total_seconds := int(time_elapsed)
	var mins := total_seconds / 60
	var secs := total_seconds % 60

	$UI/time/clockContainer/hora.text = "%02d:%02d" % [mins, secs]
	





func _on_tienda_button_pressed() -> void:
	if get_node("UI").get_node("Tienda_o_Ui").cerrado:
		get_node("UI").get_node("TiendaUi").open()
	else:
		get_node("UI"). get_node("Tienda_o_Ui").close()
