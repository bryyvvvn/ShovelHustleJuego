extends Label

@export var player_ref: Node
var bounty : int = 550

func set_bounty(a : int):
	bounty = a

func _process(delta):
	text = str(player_ref.money) + "  CUOTA: " + str(bounty)
