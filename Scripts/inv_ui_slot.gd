extends Button

@onready var container: CenterContainer = $CenterContainer

var itemStackGui: ItemStackGui
var index: int
var inventory: Inv 

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
