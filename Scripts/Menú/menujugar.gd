extends Control

func _ready():
	Music.play_track(0)
	
func _on_multiplayer_pressed() -> void:
	Vfx.play_vfx(0)
	get_tree().change_scene_to_file("res://Scenes/Menu/multiplayermenu.tscn")



func _on_atrás_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/Menu.tscn") 


func _on_singleplayer_pressed() -> void:
	Vfx.play_vfx(0)
	var loading = preload("res://Scenes/in_game/loadingscreen.tscn").instantiate()
	loading.process_mode = Node.PROCESS_MODE_ALWAYS  
	get_tree().root.add_child(loading)
	get_tree().change_scene_to_file("res://Scenes/in_game/loadingscreen.tscn") 
