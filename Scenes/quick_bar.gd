extends Panel

@onready var inventory: Inv = preload("res://Scenes/Inventario/playerInv.tres")
@onready var slots: Array = $Container.get_children()

var currently_selected: int = 0

func _ready():
	update()
	inventory.update.connect(update)
	
func update() -> void:
	for i in range(slots.size()):
		var inventory_slot: InvSlot = inventory.slots[i]
		slots[i].update_to_slot(inventory_slot)
