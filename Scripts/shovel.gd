extends Node

@export var minigame_scene : PackedScene 

@export var difficulty_multiplier := 1.0
var current_tile := Vector2i.ZERO

func cavar(mouse_pos: Vector2i)->void:
	print("iniciar minijuego")

func calculate_success(hardness: float) -> float:
	return 1.0 - (hardness * difficulty_multiplier)

func show_minigame(success_chance: float):
	pass
	#var minigame = preload("res://scenesawdsaa/MiniGame.tscn").instantiate()
	#minigame.setup(success_chance, current_tile)
	#get_tree().current_scene.add_child(minigame)
