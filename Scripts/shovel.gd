extends Node

@export var minigame_scene : PackedScene 
@export var difficulty_multiplier := 1.0

var current_tile := Vector2i.ZERO

func cavar(tile_pos: Vector2i)->bool: ##poquito redundante, pero más intuitivo (de pala se llama a cavar)
	current_tile = tile_pos
	return await show_minigame()
	

func show_minigame()->bool:
	var minigame = minigame_scene.instantiate()
	minigame.setup(1, 1)  
	#minigame.setup(dia, pala)
	#get_tree().current_scene.add_child(minigame)
	get_tree().current_scene.get_node("UI").add_child(minigame)
	get_tree().current_scene.get_node("player").is_active = false
	get_tree().current_scene.get_node("player").get_node("AnimatedSprite2D").play("idle_down")
	var result = await minigame.minigame_result
	get_tree().current_scene.get_node("player").is_active = true
	return result
