
extends Sprite2D

# Configuración del movimiento vertical
@export var rango_movimiento: float = 35.0       # Distancia vertical máxima (píxeles)
@export var velocidad_movimiento: float = 20.0   # Velocidad del movimiento vertical

var posicion_inicial: Vector2
var progreso: float = 0.0

func _ready():
	posicion_inicial = position
	# Inicio aleatorio para variedad
	progreso = randf_range(0, rango_movimiento * 2)

func _process(delta):
	# Movimiento vertical con rebote
	progreso = fmod(progreso + delta * velocidad_movimiento, rango_movimiento * 2)
	position.y = posicion_inicial.y + abs(progreso - rango_movimiento) - rango_movimiento
	
	# Opcional: Rotación sutil sincronizada
	# rotation = sin(progreso * 0.05) * 0.03  # Pequeña inclinación (±0.03 radianes)
