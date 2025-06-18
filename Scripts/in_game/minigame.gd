extends Control

signal minigame_result(success: bool)

@export var gravity := 100
@export var lift_speed := 100
@export var green_zone_height := 29 



var velocity := 0.0
var active := true

var direction := 1
var zone_speed := 80.0
var vali = true
var posisiones_arr: Array[float]

func setup(dia: int, pala: int):
	dia = 1
	var min_dia: int = 1
	var max_dia: int = 10

	var dificultad_dia: float = clamp((dia - min_dia) / float(max_dia - min_dia), 0.0, 1.0)
	var poder_pala: float = clamp((pala - min_dia) / float(max_dia - min_dia), 0.0, 1.0)

	var speed_param: float = 1.0 - dificultad_dia
	var height_param: float = clamp(poder_pala - dificultad_dia, -1.0, 1.0)

	zone_speed = 80.0 + dificultad_dia * 200.0

	green_zone_height = clamp(29.0 * (1.0 - height_param), 10.0, 100.0)
	$Bar/zonaOro.size.y = green_zone_height

	gravity = lerp(150.0, 500.0, dificultad_dia)
	lift_speed = lerp(30.0, 80.0, dificultad_dia)

	gravity = lerp(150.0, 500.0, dificultad_dia)  

	lift_speed = lerp(200.0, 600.0, dificultad_dia)  

func _ready():
	$Bar/zonaOro.size.y = green_zone_height
	#$Bar/zonaOro.position.y = 
	$Bar/pala.position.y = 210
	

func _process(delta):
	if !active:
		return
	
	var cursor = $Bar/pala
	var y = cursor.position.y
	
	velocity = gravity

	if Input.is_action_just_pressed('right_click') and vali:
		vali = false
		var start_y: float = cursor.position.y
		var end_y: float = clamp(start_y - lift_speed, 0.0, $Bar.size.y - cursor.size.y)

		var tween = create_tween()
		tween.tween_method(
			func(t): cursor.position.y = lerp(start_y, end_y, t),
				0.0, 1.0, 0.25  # ← adjust duration to your liking
			)
		tween.connect("finished", Callable(self, "_on_tween_finished"))
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		#velocity = -lift_speed
		
	#else:
		#if int(Time.get_ticks_msec() / 100) % 2 == 0:
			#velocity = gravity
		#else:
			#velocity = 0

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
	posisiones_arr.append(zone.position.y)
	
	

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
	
func _on_tween_finished():
	vali = true
