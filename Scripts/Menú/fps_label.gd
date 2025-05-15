extends Label

func _ready() -> void:
	GlobalSettings.connect("fps_display", Callable(self, "_on_fps_display"))
	GlobalSettings.change_fps(true) # <-- fuerza activación solo para testeo
	
func _process(delta: float) -> void:
	text = "FPS: %s"% Engine.get_frames_per_second()

func _on_fps_display(value):
	visible =value
