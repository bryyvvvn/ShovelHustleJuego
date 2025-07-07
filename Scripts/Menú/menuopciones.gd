extends Control

func _on_volumen_pressed() -> void:
	
	Vfx.play_sfx(2)
	pass # Replace with function body.
	



func _on_resolución_pressed() -> void:
	Vfx.play_sfx(2)


func _on_atrás_pressed() -> void:
	
	get_tree().change_scene_to_file("res://Scenes/Menú.tscn")
	Vfx.play_sfx(2)
