extends CharacterBody2D

@export var speed := 100.0
func _ready():
	$Camera2D.zoom = Vector2(1, 1) 
	
func _physics_process(delta):
	var direction := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()  # Diagonal speed fix
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			$AnimatedSprite2D.animation = "walk_right" if direction.x > 0 else "walk_left"
		else:
			$AnimatedSprite2D.animation = "walk_down" if direction.y > 0 else "walk_up"
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	if Input.is_action_just_pressed("zoom_in"):
		$Camera2D.zoom *= 1.1
	elif Input.is_action_just_pressed("zoom_out"):
		$Camera2D.zoom *= 0.9
		
	$Camera2D.zoom.x = clamp($Camera2D.zoom.x, 1.5, 3)
	$Camera2D.zoom.y = clamp($Camera2D.zoom.y, 1.5, 3)
