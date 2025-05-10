extends Area2D

@export var data: objectData 

func _ready():
	if data:
		$Sprite2D.texture = get_texture_for(data.nombre)

func get_texture_for(tipo: String) -> Texture2D:
	match tipo:
		"diamante": return preload("res://Assets/Sprites/objects/diamante.png")
		"carbon": return preload("res://Assets/Sprites/objects/carbon.png")
		"oro": return preload("res://Assets/Sprites/objects/oro.png")
		"plata": return preload("res://Assets/Sprites/objects/plata.png")
		"hierro": return preload("res://Assets/Sprites/objects/hierro.png")
		"diamante": return preload("res://Assets/Sprites/objects/diamante.png")
		"diamante": return preload("res://Assets/Sprites/objects/diamante.png")
		"diamante": return preload("res://Assets/Sprites/objects/diamante.png")
		_:
			return preload("res://Assets/Sprites/objects/piedra.png")

func on_collected():
	var player = get_tree().current_scene.get_node("Player")
	player.agregar_a_inventario(data)
	queue_free()
