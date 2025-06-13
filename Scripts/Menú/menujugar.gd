extends Control



#func _on_singleplayer_pressed() -> void:
#	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	
	
func _on_multiplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/multiplayermenu.tscn")




func _on_atrás_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/Menu.tscn") 


func _on_singleplayer_pressed() -> void:
	var loading = preload("res://Scenes/loadingscreen.tscn").instantiate()
	loading.process_mode = Node.PROCESS_MODE_ALWAYS  
	get_tree().root.add_child(loading)
