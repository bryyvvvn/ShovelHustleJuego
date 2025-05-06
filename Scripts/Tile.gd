extends Node2D

@export var flag := true


func _ready() -> void:
	set_flag(flag)

func set_flag(new_flag):
	$ColorRect.size = Vector2(32, 32)
	flag = new_flag
	if flag:
		$ColorRect.color = Color.GREEN
	else:
		$ColorRect.color = Color.SADDLE_BROWN

		 
