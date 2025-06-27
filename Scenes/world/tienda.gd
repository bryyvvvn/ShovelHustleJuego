extends Area2D

@onready var player = null
@onready var siguiente_anim = ""

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player.get_parent().get_node("UI").get_node("TiendaUi").enabled = true;
		
		$AnimatedSprite2D.play("Asomarse")


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player.get_parent().get_node("UI").get_node("TiendaUi").enabled = false;
		
		siguiente_anim = "Escondido"
		$AnimatedSprite2D.play("Esconderse")


func _on_animated_sprite_2d_animation_finished() -> void:
	if siguiente_anim != "":
		$AnimatedSprite2D.play(siguiente_anim)
		siguiente_anim = ""
		
