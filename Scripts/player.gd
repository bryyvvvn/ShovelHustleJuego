extends CharacterBody2D

@export var speed := 100.0

func _ready():
	$Camera2D.zoom = Vector2(0, 0) 

var last_direction := Vector2.DOWN #la última dirección que tuvo el personaje (para play idle animations)	

func direccion()->Vector2:
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
	var direction = direccion()

	if direction != Vector2.ZERO:
		direction = direction.normalized()  # Diagonal speed fix
		velocity = direction * speed
		move_and_slide()
		
		last_direction = direction
		
		
		
		if abs(direction.x) > abs(direction.y):
			$AnimatedSprite2D.animation = "walk_right" if direction.x > 0 else "walk_left"
		else:
			$AnimatedSprite2D.animation = "walk_down" if direction.y > 0 else "walk_up"
		
	else:
		velocity = Vector2.ZERO
		
		if abs(last_direction.x) > abs(last_direction.y):
			$AnimatedSprite2D.animation = "idle_right" if last_direction.x > 0 else "idle_left"
		else:
			$AnimatedSprite2D.animation = "idle_down" if last_direction.y > 0 else "idle_up"
	$AnimatedSprite2D.play()
	
	if Input.is_action_just_pressed("zoom_in"):
		$Camera2D.zoom *= 1.1
	elif Input.is_action_just_pressed("zoom_out"):
		$Camera2D.zoom *= 0.9
		
	$Camera2D.zoom.x = clamp($Camera2D.zoom.x, -1, 3)
	$Camera2D.zoom.y = clamp($Camera2D.zoom.y, -1, 3)


@onready var tilemap = get_parent().get_node("Scenes/proc_world_2/TileMap")

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			try_dig()

func try_dig():
	var mouse_pos = get_global_mouse_position()
	var tile_pos = tilemap.local_to_map(mouse_pos)

	if tilemap.puede_excavar(tile_pos):
		iniciar_minijuego(tile_pos)

func iniciar_minijuego(tile_pos: Vector2i):
	var minigame = preload("res://scenes/minigame.tscn").instantiate()
	minigame.setup(1, 1)  # You can replace with day, shovel upgrade, etc.
	minigame.connect("minigame_result", Callable(self, "_on_minigame_result").bind(tile_pos))
	get_tree().current_scene.add_child(minigame)

func _on_minigame_result(success: bool, tile_pos: Vector2i):
	if success:
		tilemap.excavar(tile_pos)
	else:
		print("❌ Fallo la excavación en ", tile_pos)
