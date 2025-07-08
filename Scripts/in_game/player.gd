extends CharacterBody2D

@export var inv: Inv
@export var speed_base := 100.0
@export var tienda_scene : PackedScene

var tienda
var game_scene : Node2D

var block_zoom = false
var enable_to_open := true
var is_active := true
var max_energy := 100.0
var can_sleep := false
var is_in_bed := false
var water_speed = speed_base * 0.5
var speed = speed_base

var water_afect := true
var _water_timer := Timer.new()
var original_speed = speed
var speed_timer = Timer.new()

# --- Propiedades con protección ---
var _energy := 100.0
var _money := 0

var energy:
	get:
		return _energy
	set(value):
		_energy = clamp(value, 0.0, max_energy)

var money:
	get:
		return _money
	set(value):
		_money = max(0, value)


func erase_energy():
	energy -= 8

func res_energy():
	energy = max_energy

func _ready():
	$Camera2D.zoom = Vector2(1, 1) 
	add_child(speed_timer)
	speed_timer.connect("timeout", Callable(self, "_on_speed_timer_timeout"))
	add_child(_water_timer)
	_water_timer.connect("timeout", Callable(self, "_on_water_timer_timeout"))


func reduce_speed_temporarily(duration: float, factor: float) -> void:
	if speed_timer.is_stopped():
		original_speed = speed_base
		speed_base *= factor
		speed_timer.start(duration)
	else:
		speed_timer.stop()
		speed_base = original_speed * factor
		speed_timer.start(duration)

func _on_speed_timer_timeout():
	speed_base = original_speed

func activate_water_afect(duration: float) -> void:
	water_afect = false
	_water_timer.start(duration)

func _on_water_timer_timeout():
	water_afect = true

var last_direction := Vector2.DOWN #la última dirección que tuvo el personaje (para play idle animations)

func direccion() -> Vector2:
	var direction := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	return direction

func _physics_process(delta):
	if can_sleep and Input.is_action_just_pressed("tienda"):
		is_in_bed = true

	if !is_active:
		return

	var direction = direccion()
	if direction != Vector2.ZERO:
		if !Vfx.is_playing_vfx():
			Vfx.play_vfx(0)

		direction = direction.normalized()
		velocity = direction * speed
		move_and_slide()

		last_direction = direction

		if abs(direction.x) > abs(direction.y):
			$AnimatedSprite2D.animation = "walk_right" if direction.x > 0 else "walk_left"
		else:
			$AnimatedSprite2D.animation = "walk_down" if direction.y > 0 else "walk_up"
	else:
		if Vfx.is_playing_vfx():
			Vfx.stop_vfx()

		velocity = Vector2.ZERO

		if abs(last_direction.x) > abs(last_direction.y):
			$AnimatedSprite2D.animation = "idle_right" if last_direction.x > 0 else "idle_left"
		else:
			$AnimatedSprite2D.animation = "idle_down" if last_direction.y > 0 else "idle_up"
	
	$AnimatedSprite2D.play()

	if Input.is_action_just_pressed("zoom_in") and !block_zoom:
		$Camera2D.zoom *= 1.1
	elif Input.is_action_just_pressed("zoom_out") and !block_zoom:
		$Camera2D.zoom *= 0.9

	$Camera2D.zoom.x = clamp($Camera2D.zoom.x, -1, 3)
	$Camera2D.zoom.y = clamp($Camera2D.zoom.y, -1, 3)

func player():
	pass

func collect(item):
	Vfx.play_sfx(1)
	inv.insert(item)

func update_money(in_money: int) -> void:
	money += in_money

# --- FUNCIÓN QUE SE LLAMA CUANDO UN ÍTEM ES "SOLTADO" DEL INVENTARIO ---
func _on_item_dropped(item_data: objectData, amount: int, drop_position: Vector2):
	if item_data and item_data.item_scene:
		for i in range(amount):
			var dropped_item_instance = item_data.item_scene.instantiate()

			var offset_x = randf_range(-8, 8)
			var offset_y = randf_range(-8, 8)
			dropped_item_instance.global_position = drop_position + Vector2(offset_x, offset_y)

			get_parent().add_child(dropped_item_instance)

			print("Player: Instanciado '%s' x %d en la posición %s" % [item_data.nombre, 1, dropped_item_instance.global_position])
	else:
		printerr("Player: ERROR: No se pudo soltar el ítem. Datos del ítem o 'item_scene' inválidos para '%s'." % (item_data.nombre if item_data else "Unknown Item"))
