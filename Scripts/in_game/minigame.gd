extends Control

signal minigame_result(success: bool)

@export var base_gravity := 500.0
@export var base_lift := -300.0
@export var green_zone_base_height := 30.0

var right_click_pressed: bool = false
var velocity: float = 0.0
@export var gravity := 400.0
@export var lift_force := 300.0
var direction: int = 1
@export var zone_speed: float = 80.0
var active: bool = true
var zone_direction: int = 1

var gravedad: float
var impulso: float
var green_zone_height: float
var dificultad: float

@onready var cursor := $Bar/pala
@onready var green_zone := $Bar/zonaOro
@onready var bar := $Bar

func setup(dia: int, pala: int) -> void:
	await ready  
	dificultad = clamp((dia - 1) / 9.0, 0.0, 1.0)

	gravedad = lerp(base_gravity, base_gravity * 1.5, dificultad)
	impulso = lerp(base_lift, base_lift * 0.05, dificultad)

	green_zone_height = clamp(green_zone_base_height * (1.0 - dificultad), 10.0, 100.0)
	green_zone.size = Vector2(green_zone.size.x, green_zone_height)

	cursor.position.y = 210
	green_zone.position.y = 60

func _process(delta):
	if !active:
		return

	var cursor = $Bar/pala
	var y = cursor.position.y

	# Right click makes the shovel go up
	if right_click_pressed:
		velocity = -lift_force
	else:
		velocity += gravity * delta*1.5  

	y += velocity * delta
	y = clamp(y, 0, $Bar.size.y - cursor.size.y)
	cursor.position.y = y

	
	var zone = $Bar/zonaOro
	zone.position.y += direction * zone_speed * delta

	if zone.position.y <= 0:
		direction = 1
	elif zone.position.y + zone.size.y >= $Bar.size.y:
		direction = -1

func _input(event):
	if event is InputEventMouseButton:
		# Right click controls lift
		if event.button_index == MOUSE_BUTTON_RIGHT:
			right_click_pressed = event.pressed

		# Left click ends game when released
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			active = false
			var success = cursor_in_green_zone()
			emit_signal("minigame_result", success)
			queue_free()

func cursor_in_green_zone() -> bool:
	var cursor_center_y = cursor.global_position.y + cursor.size.y / 2
	var zone_y = green_zone.global_position.y
	var zone_h = green_zone.size.y
	return cursor_center_y >= zone_y and cursor_center_y <= zone_y + zone_h
