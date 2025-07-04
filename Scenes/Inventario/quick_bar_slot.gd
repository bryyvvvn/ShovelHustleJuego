extends Button

@onready var background_sprite: Sprite2D = $Sprite2D
@onready var item_stack_gui: ItemStackGui = $CenterContainer/Panel

func update_to_slot(slot: InvSlot) -> void:
	if !slot.item:
		item_stack_gui.visible = false
		return
	
	item_stack_gui.InventorySlot = slot
	item_stack_gui.update()
	item_stack_gui.visible = true
	
	
