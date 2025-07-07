extends CanvasLayer

func _ready():
	get_tree().paused = true  # pausa el juego cuando aparece

func _on_Reanudar_pressed():
	
	get_tree().paused = false
	Vfx.play_sfx(2)
	queue_free()

	
func _on_Salir_pressed():
	Vfx.play_sfx(2)
	Music.stop_song()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menu/Menu.tscn")
