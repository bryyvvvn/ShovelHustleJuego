extends Control

@onready var energia = $Panel/ColorRect
var full_width := 0.0

func _ready():
	full_width = energia.size.x
	
func set_energy(ratio: float)-> void:
	ratio = clamp(ratio, 0.0, 1.0)
	energia.size.x = full_width * ratio
