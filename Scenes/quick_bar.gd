extends HBoxContainer

@onready var inventory: Inv = preload("res://Inventario/playerInv.tres")
@onready var slots: Array = get_children()

func _ready():
	update()
	inventory.update.connect(update)
	
func update() -> void:
	for i in range(slots.size()):
		var inventory_slot: InvSlot = inventory.slots[i]
		slots[i].update_to_slot(inventory_slot)
