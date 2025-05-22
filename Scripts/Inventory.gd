extends Resource

class_name Inv

signal update

@export var slots: Array[InvSlot]

func insert(item: objectData): 
	var itemslots = slots.filter(func(slot): return !slot.is_empty() and slot.item == item and slot.amount < slot.item.StackSize)
	
	if !itemslots.is_empty():
		itemslots[0].amount += 1
	else:
		var emptyslots = slots.filter(func(slot): return slot.is_empty())
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
	
func clear_inventory():
	slots.clear()
	# Crear 24 slots vacíos correctamente inicializados
	for i in range(24):
		var slot = InvSlot.new()
		slot.item = null  # Esto asegura que cada slot está vacío inicialmente
		slot.amount = 0  # Inicializar la cantidad a 0
		slots.append(slot)
	print(slots)
