extends Button

@onready var mensaje_sprite: Sprite2D = $Sprite2D
@onready var mensaje_label: Label = $Sprite2D/Label

func _ready() -> void:
	mensaje_sprite.visible = false
	mensaje_label.visible = false
	
	self.pressed.connect(switch)
	
func switch():
	if mensaje_label.visible:
		esconder()
	else:
		mostrar()
func mostrar():
	mensaje_sprite.visible = true
	mensaje_label.visible = true 

func esconder():
	mensaje_sprite.visible = false
	mensaje_label.visible = false 
