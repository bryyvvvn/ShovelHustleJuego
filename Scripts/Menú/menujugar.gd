extends Control



func _on_singleplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	
	
func _on_multiplayer_pressed() -> void:
	pass # Replace with function body.




func _on_atrás_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/Menu.tscn") # Replace with function body.
