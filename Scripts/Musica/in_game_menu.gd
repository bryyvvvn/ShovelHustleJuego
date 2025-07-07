extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_Reanudar_pressed():
	Vfx.play_sfx(2)
	queue_free()

	
func _on_Salir_pressed():
	Vfx.play_sfx(2)
	Music.stop_song()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menu/Menu.tscn")
