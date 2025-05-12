extends Control

signal minigame_result(success: bool)

@export var gravity := 200.0
@export var lift_speed := 300.0
@export var green_zone_height := 60.0

var velocity := 0.0
var active := true

func setup(dia: int, pala: float):
	var dificultad_dia = clamp((dia - 1) * 0.1, 0.0, 0.6)  
	var poder_total = pala - dificultad_dia                
	var exito = clamp(poder_total, 0.1, 1.0)              

	green_zone_height = clamp(200.0 * exito, 30, 100)
	gravity = 150.0 + (1.0 - exito) * 200.0
	lift_speed = 250.0 - (1.0 - exito) * 100.0

	$Bar/zonaOro.size.y = green_zone_height
	$Bar/pala.position.y = $Bar.size.y / 2

func _ready():
	$Bar/zonaOro.size.y = green_zone_height
	$Bar/pala.position.y = $Bar.size.y / 2

func _process(delta):
	if !active:
		return

	var cursor = $Bar/pala
	var y = cursor.position.y

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		velocity = -lift_speed
	else:
		velocity += gravity * delta

	y += velocity * delta
	y = clamp(y, 0, $Bar.size.y - cursor.size.y)
	cursor.position.y = y

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			# Left mouse button was released
			active = false
			var success = cursor_in_green_zone()
			emit_signal("minigame_result", success)
			queue_free()

func cursor_in_green_zone() -> bool:
	var cursor_y = $Bar/pala.global_position.y
	var green_y = $Bar/zonaOro.global_position.y
	var green_h = $Bar/zonaOro.size.y
	return cursor_y >= green_y and cursor_y <= green_y + green_h
