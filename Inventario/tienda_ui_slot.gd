extends Button

@onready var container: CenterContainer = $CenterContainer

var itemStackGui: ItemStackGui

func insert(isg: ItemStackGui):
	if itemStackGui:  # Si ya hay un item, bórralo primero
		container.remove_child(itemStackGui)
		itemStackGui.queue_free()
	
	itemStackGui = isg
	container.add_child(itemStackGui)

	# Como es tienda, "vendemos" el item (desaparece)
	isg.InventorySlot.amount = 0
	isg.queue_free()
	itemStackGui = null

func isEmpty():
	return itemStackGui == null
