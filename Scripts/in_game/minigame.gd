extends Control

signal minigame_result(success: bool)

@export var base_gravity := 500.0
@export var base_lift := -300.0
@export var green_zone_base_height := 40.0

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
var facilidad: float

var right_click_just_pressed := false
@onready var modo_alternativo: bool = get_parent().get_parent().shovel.modo_alternativo

@onready var cursor := $Bar/pala
@onready var green_zone := $Bar/zonaOro
@onready var bar := $Bar

func setup(dia: int, pala: int) -> void:
	await ready  
	dificultad = clamp((dia - 1) / 4, 0.0, 1.0)
	facilidad = clamp((pala - 1) / 4, 0.0, dificultad)
	gravedad = lerp(base_gravity, base_gravity * 1.5, dificultad)
	impulso = lerp(base_lift, base_lift * 0.05, dificultad)

	green_zone_height = clamp(green_zone_base_height * (1 - (dificultad-facilidad)), 5.0, 130.0)
	green_zone.size = Vector2(green_zone.size.x, green_zone_height)

	cursor.position.y = 210
	green_zone.position.y = 60

func _process(delta):
	if not active:
		return

	# Aplicar física a la pala
	if right_click_just_pressed:
		if velocity >= 0:  # Solo permite bombear si no está subiendo
			velocity = -lift_force
		right_click_just_pressed = false
	else:
		velocity += gravity * delta * 1.5

	var y = cursor.position.y
	y += velocity * delta
	y = clamp(y, 0, bar.size.y - cursor.size.y)
	cursor.position.y = y

	# Movimiento de la zona verde
	if modo_alternativo:
		var t = Time.get_ticks_msec() / 1000.0
		var erratic = sin(t * 4.5) * 0.5 + sin(t * 3.8) * 0.3
		var pos = lerp(0.0, bar.size.y - green_zone.size.y, erratic * 0.5 + 0.5)
		green_zone.position.y = pos
	else:
		green_zone.position.y += direction * zone_speed * delta
		if green_zone.position.y <= 0:
			direction = 1
		elif green_zone.position.y + green_zone.size.y >= bar.size.y:
			direction = -1

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				right_click_just_pressed = true

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
