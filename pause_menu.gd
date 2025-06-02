extends CanvasLayer

func _ready():
	get_tree().paused = true  # pausa el juego cuando aparece

func _on_Reanudar_pressed():
	
	get_tree().paused = false
	Vfx.play_vfx(0)
	queue_free()

func _on_Guardar_pressed():
	Vfx.play_vfx(0)
	#SaveSystem.save_game()
	print("pendiente: guardar juego")
	
func _on_Salir_pressed():
	Vfx.play_vfx(0)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menu/Menu.tscn")
