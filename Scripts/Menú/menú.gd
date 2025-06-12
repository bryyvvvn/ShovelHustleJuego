extends Control
# Precarga la escena del menú de opciones
var opciones_menu_scene = preload("res://Scenes/Menu/OpcionesMenu.tscn")  # Ajusta la ruta según tu estructura


func _on_salir_pressed() -> void:
	get_tree().quit()
	
func _on_opciones_pressed() -> void:
	$OpcionesMenu.popup()


func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/menujugar.tscn")
