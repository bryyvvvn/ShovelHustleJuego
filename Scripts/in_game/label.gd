extends Label

@export var player_ref: Node


func _process(delta):
	text = str(player_ref.money)
