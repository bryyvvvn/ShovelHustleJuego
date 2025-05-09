extends CharacterBody2D

const acceleration = 460
const max_speed = 225
var item_name

var player = null
var being_picked_up = false

func _ready():
	item_name = "coin 2"

func _physics_process(delta):
	var velocity = Vector2.ZERO
	
	if being_picked_up == true:
		var dir = global_position.direction_to(player.global_position)
		velocity = velocity.move_toward(dir * max_speed, acceleration * delta)
		
		var distance = global_position.direction_to(player.global_position)
		if distance.x or distance.y < 10:
			queue_free()
	
	velocity = move_and_slide()

func pick_up_item(body):
	player = body
	being_picked_up = true
