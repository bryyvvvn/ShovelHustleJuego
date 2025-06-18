extends Resource

class_name InvSlot

@export var item: objectData 
@export var amount: int

func _init():
	item = null
	amount = 0
	
func is_empty() -> bool:
	return item == null or amount <= 0
