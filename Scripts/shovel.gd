extends Node

@export var difficulty_multiplier := 1.0
var current_tile := Vector2i.ZERO

func start_excavation(tile_pos: Vector2i):
	current_tile = tile_pos
	var hardness = get_parent().get_parent().get_node("GameState").get_tile_hardness(tile_pos)
	var success_chance = calculate_success(hardness)
	show_minigame(success_chance)

func calculate_success(hardness: float) -> float:
	return 1.0 - (hardness * difficulty_multiplier)

func show_minigame(success_chance: float):
	var minigame = preload("res://scenesawdsaa/MiniGame.tscn").instantiate()
	minigame.setup(success_chance, current_tile)
	get_tree().current_scene.add_child(minigame)
