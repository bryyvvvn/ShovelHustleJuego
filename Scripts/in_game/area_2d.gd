extends Area2D

var data: objectData 
var player_in_area = null
var player = null

func _ready():
	if data:
		$Sprite2D.texture = data.texture


func on_collected():
	var player = get_tree().current_scene.get_node("Player")
	player.agregar_a_inventario(data)
	queue_free()
	


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area == true
		player = body
		player.collect(data)
		self.queue_free()


"""func _on_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area == false """
