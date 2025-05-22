extends Control


func _ready():
	Music.play_track(0)

func _on_salir_pressed() -> void:
	get_tree().quit()
	
func _on_opciones_pressed() -> void:
	$OpcionesMenu.popup()


func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/menujugar.tscn")
