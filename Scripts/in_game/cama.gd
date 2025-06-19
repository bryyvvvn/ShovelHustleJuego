extends Area2D

var player = null

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player.can_sleep = true;


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		print("hola")
		player = body
		player.can_sleep = false;
