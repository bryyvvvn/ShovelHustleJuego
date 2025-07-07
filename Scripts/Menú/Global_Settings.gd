extends Node

signal fps_display(value)
signal brillo_updated(value)
	
func change_displayMode(toggle: bool):
	var new_mode = DisplayServer.WINDOW_MODE_FULLSCREEN if toggle else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(new_mode)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)

func change_fps(toggle: bool):
	emit_signal("fps_display", toggle)
	
func update_brillo(value):
	emit_signal("brillo_updated", value)


#Audio
#func update_volumen_maestro(bus_idx, vol):
#	AudioServer.set_bus_volume_db(bus_idx,vol if vol > -50 else AudioServer.set_bus_mute(bus_idx,true))
#	match bus_idx:
		
