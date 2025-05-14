extends Panel
class_name ItemStackGui

@onready var item_visual: Sprite2D = $item_display
@onready var amount_text: Label = $Label

var InventorySlot: InvSlot 

func update():
	if !InventorySlot || !InventorySlot.item: return

	item_visual.visible = true
	item_visual.texture = InventorySlot.item.texture_inventory
		
	if InventorySlot.amount >= 1: 
		amount_text.visible = true
		amount_text.text = str(InventorySlot.amount)
	else:
		amount_text.visible = false
