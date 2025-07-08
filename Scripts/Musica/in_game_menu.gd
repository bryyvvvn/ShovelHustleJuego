extends CanvasLayer

#signal quit_pressed

func _ready() -> void:
	pass

func _on_Reanudar_pressed():
	Vfx.play_sfx(2)
	queue_free()

	
func _on_Salir_pressed():
	Vfx.play_sfx(2)
	Music.stop_song()
	get_parent().get_node("online").quitMatch()
	get_tree().change_scene_to_file("res://Scripts/Menú/multiplayermenu.gd")
