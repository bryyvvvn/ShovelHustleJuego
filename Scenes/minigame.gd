extends Control

signal minigame_result(success: bool)

@export var gravity := 140
@export var lift_speed := 100
@export var green_zone_height := 29 

var velocity := 0.0
var active := true

var direction := 1
var zone_speed := 80.0

func setup(dia: int, pala: float):
	var dificultad_dia = clamp((dia - 1) * 0.1, 0.0, 0.6)  
	var poder_total = pala - dificultad_dia                
	var exito = clamp(poder_total, 0.1, 1.0)       
	zone_speed = 80.0 + (1.0 - exito) * 60.0       

	green_zone_height = clamp(29 * exito, 10, 100)
	gravity = 140.0 + (1.0 - exito) * 200.0
	lift_speed = 100.0 - (1.0 - exito) * 100.0

	$Bar/zonaOro.size.y = green_zone_height
	$Bar/pala.position.y = 99

func _ready():
	$Bar/zonaOro.size.y = green_zone_height
	$Bar/pala.position.y = 99

func _process(delta):
	if !active:
		return
	
	var cursor = $Bar/pala
	var y = cursor.position.y

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		velocity = -lift_speed
	else:
		if int(Time.get_ticks_msec() / 100) % 2 == 0:
			velocity = gravity
		else:
			velocity = 0

	y += velocity * delta
	y = clamp(y, 0, $Bar.size.y - cursor.size.y)
	cursor.position.y = y
	
	var zone = $Bar/zonaOro
	#movimiento vertical
	zone.position.y += direction * zone_speed * delta

	if zone.position.y <= 0:
		direction = 1
	elif zone.position.y + zone.size.y >= 205:
		direction = -1
	
	

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			active = false
			var success = cursor_in_green_zone()
			emit_signal("minigame_result", success)
			queue_free()

func cursor_in_green_zone() -> bool:
	var cursor_y = $Bar/pala.global_position.y
	var green_y = $Bar/zonaOro.global_position.y
	var green_h = $Bar/zonaOro.size.y
	return cursor_y >= green_y and cursor_y <= green_y + green_h
