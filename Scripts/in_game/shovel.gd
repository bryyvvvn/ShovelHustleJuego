extends Node

@export var minigame_scene : PackedScene 
@export var difficulty_multiplier := 1.0

var current_tile := Vector2i.ZERO
var shovel_level: int = 1
var modo_alternativo = false


func cavar(tile_pos: Vector2i, day: int)->bool: ##poquito redundante, pero más intuitivo (de pala se llama a cavar)
	current_tile = tile_pos
	shovel_level = get_parent().inventory.contar_palas()
	print(shovel_level)
	if tile_pos in get_parent().tile_map.rich_zones:
		modo_alternativo = true
	else:
		modo_alternativo = false
	return await show_minigame(day, shovel_level)
	

func show_minigame(day: int, shovel_level:int)->bool:
	var minigame = minigame_scene.instantiate()
	minigame.setup(day, shovel_level)  
	#minigame.setup(dia, pala)
	#get_tree().current_scene.add_child(minigame)
	get_tree().current_scene.get_node("UI").add_child(minigame)
	get_tree().current_scene.get_node("player").is_active = false
	get_tree().current_scene.get_node("player").get_node("AnimatedSprite2D").play("idle_down")
	var result = await minigame.minigame_result
	get_tree().current_scene.get_node("player").is_active = true
	return result
