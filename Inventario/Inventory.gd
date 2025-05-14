extends Resource

class_name Inv

signal update

@export var slots: Array[InvSlot]

func insert(item: objectData): 
	var itemslots = slots.filter(func(slot): return slot.item == item && slot.amount < slot.item.StackSize)
	if !itemslots.is_empty():
		itemslots[0].amount += 1
	else:
		var emptyslots = slots.filter(func(slot): return slot.item == null)
		if !emptyslots.is_empty():
			emptyslots[0].item = item
			emptyslots[0].amount = 1
	update.emit()

func removeSlot(inventorySlot: InvSlot):
	var index = slots.find(inventorySlot)
	if index < 0: return
	
	slots[index] = InvSlot.new()

func InsertSlot(index: int, inventorySlot: InvSlot):
	slots[index] = inventorySlot
