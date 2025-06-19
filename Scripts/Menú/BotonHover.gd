extends Button

@export var escala_hover := 1.1
@export var duracion_animacion := 0.2
@export var tamano_fuente_extra := 4

var tamano_fuente_original := 0

func _ready():
	# Guardar tamaño original de fuente si existe
	if has_theme_font_size("font_size"):
		tamano_fuente_original = get_theme_font_size("font_size")
	
	# Conectar señales
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_hover_exit)
	


func _on_hover():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(escala_hover, escala_hover), duracion_animacion)
	
	if tamano_fuente_original > 0:
		tween.parallel().tween_property(self, "theme_override_font_sizes/font_size", 
									  tamano_fuente_original + tamano_fuente_extra, 
									  duracion_animacion)

func _on_hover_exit():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2(1, 1), duracion_animacion)
	
	if tamano_fuente_original > 0:
		tween.parallel().tween_property(self, "theme_override_font_sizes/font_size", 
									  tamano_fuente_original, 
									  duracion_animacion)
