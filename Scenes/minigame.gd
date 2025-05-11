extends Control

signal minigame_result(success: bool)

@export var gravity := 200.0
@export var lift_speed := 300.0
@export var green_zone_height := 60.0

var velocity := 0.0
var active := true

func _ready():
	$GreenZone.size.y = green_zone_height
	$Cursor.rect_position.y = $Bar.rect_size.y / 2

func _process(delta):
	if !active:
		return

	var cursor = $Cursor
	var y = cursor.rect_position.y

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		velocity = -lift_speed
	else:
		velocity += gravity * delta

	y += velocity * delta
	y = clamp(y, 0, $Bar.rect_size.y - cursor.rect_size.y)
	cursor.rect_position.y = y

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			# Left mouse button was released
			active = false
			var success = cursor_in_green_zone()
			emit_signal("minigame_result", success)
			queue_free()

func cursor_in_green_zone() -> bool:
	var cursor_y = $Cursor.rect_global_position.y
	var green_y = $GreenZone.rect_global_position.y
	var green_h = $GreenZone.rect_size.y
	return cursor_y >= green_y and cursor_y <= green_y + green_h
