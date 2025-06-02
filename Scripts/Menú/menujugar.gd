extends Control



func _on_singleplayer_pressed() -> void:
	Vfx.play_vfx(0)
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	
	
func _on_multiplayer_pressed() -> void:
	Vfx.play_vfx(0)
	get_tree().change_scene_to_file("res://Scenes/game2.tscn")




func _on_atrás_pressed() -> void:
	Vfx.play_vfx(0)
	get_tree().change_scene_to_file("res://Scenes/Menu/Menu.tscn") # Replace with function body.
