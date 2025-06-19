extends Camera2D

@export var move_speed: float = 100.0  # Velocidad de movimiento en píxeles/segundo
@export var smooth_speed: float = 5.0  # Suavidad del movimiento (1-10)
@export var start_moving: bool = true  # Si la cámara comienza a moverse automáticamente

var current_speed: float = 0.0
var is_moving: bool = false

func _ready():
	is_moving = start_moving
	current_speed = move_speed if start_moving else 0.0

func _process(delta):
	if is_moving:
		# Movimiento suave usando interpolación lineal
		current_speed = lerp(current_speed, move_speed, smooth_speed * delta)
		
		# Mover la posición de la cámara
		position.x += current_speed * delta
	else:
		current_speed = lerp(current_speed, 0.0, smooth_speed * delta)

# Funciones para controlar el movimiento desde otros scripts
func start_movement():
	is_moving = true

func stop_movement():
	is_moving = false

func set_movement_speed(new_speed: float):
	move_speed = new_speed

func toggle_movement():
	is_moving = !is_moving
