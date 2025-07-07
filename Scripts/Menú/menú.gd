extends Control


func _ready():
	if !Music.is_playing():
		Music.play_track(0)

func _on_salir_pressed() -> void:
	Vfx.play_sfx(2)
	Music.stop_music()
	get_tree().quit()
	
func _on_opciones_pressed() -> void:
	Vfx.play_sfx(2)
	$OpcionesMenu.popup()

func _on_jugar_pressed() -> void:
	Vfx.play_sfx(2)
	get_tree().change_scene_to_file("res://Scenes/Menu/menujugar.tscn")
