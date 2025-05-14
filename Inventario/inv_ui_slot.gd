extends Button

@onready var container: CenterContainer = $CenterContainer
@onready var inventory = preload("res://Inventario/playerInv.tres")

var itemStackGui: ItemStackGui
var index: int

func insert(isg: ItemStackGui):
	itemStackGui = isg
	container.add_child(itemStackGui)
	
	if !itemStackGui.InventorySlot || inventory.slots[index] == itemStackGui.InventorySlot:
		return
	inventory.InsertSlot(index, itemStackGui.InventorySlot)

func takeItem():
	var item = itemStackGui
	
	inventory.removeSlot(itemStackGui.InventorySlot)
	
	container.remove_child(itemStackGui)
	itemStackGui = null
	
	return item

func isEmpty():
	return !itemStackGui
