extends Popup

# Video Settings
@onready var display_options = $SettingsTabs/Video/MarginContainer/VideoSettings/OptionButton
@onready var FPS = $SettingsTabs/Video/MarginContainer/VideoSettings/CheckButton
@onready var brillo_boton = $SettingsTabs/Video/MarginContainer/VideoSettings/BrilloContainer/HSlider

# Audio Settings
@onready var volumen_maestro = $SettingsTabs/Audio/MarginContainer/GridContainer/HSlider4
@onready var volumen_musica = $SettingsTabs/Audio/MarginContainer/GridContainer/HSlider5
@onready var volumen_efectos = $SettingsTabs/Audio/MarginContainer/GridContainer/HSlider6

func _ready() -> void:
	# Pone el juego en pantalla completa al abrir la escena
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	# Asegura que la ventana sea redimensionable (por si vuelves a modo ventana)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
	
	FPS.button_pressed = true
	GlobalSettings.change_fps(true)

# VIDEO
func _on_option_button_item_selected(index: int) -> void:
	Vfx.play_vfx(0)
	# Si el botón tiene 2 opciones, 0: ventana, 1: fullscreen
	GlobalSettings.change_displayMode(index)

func _on_check_button_toggled(toggled_on: bool) -> void:
	GlobalSettings.change_fps(toggled_on)
	visible = false

func _on_h_slider_value_changed(value: float) -> void:
	GlobalSettings.update_brillo(value)

# AUDIO
var prev_value = 0
var plus = 0
var music_db = 0
var vfx_db = 0
func _on_h_slider_4_value_changed(value: float) -> void:
	if prev_value > value:
		plus -= 1
		Music.change_volume(music_db + plus)
		Vfx.change_volume(vfx_db + plus)
	else:
		plus += 1
		Music.change_volume(music_db + plus)
		Vfx.change_volume(vfx_db + plus)
	prev_value = value
	pass # Replace with function body.
func _on_h_slider_5_value_changed(value: float) -> void:
	music_db = value + 15
	Music.change_volume(music_db + plus)
	pass # Replace with function body.

func _on_h_slider_6_value_changed(value: float) -> void:
	vfx_db = value + 15
	Vfx.change_volume(vfx_db + plus)
	pass # Replace with function body.
	pass 
