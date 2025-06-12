extends Area2D

var player = null

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player.get_parent().get_node("UI").get_node("TiendaUi").enabled = true;


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		print("hola")
		player = body
		player.get_parent().get_node("UI").get_node("TiendaUi").enabled = false;
