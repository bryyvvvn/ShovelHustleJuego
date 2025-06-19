extends Control

@onready var inv: Inv = preload("res://Scenes/Inventario/playerInv.tres")
@onready var QuickBarSlots: Array = $NinePatchRect/HBoxContainer.get_children()
@onready var slots: Array = QuickBarSlots + $NinePatchRect/GridContainer.get_children() 
@onready var ItemStackGuiClass = preload("res://Scenes/Inventario/itemsStackGui.tscn")

var is_open = false
var itemInHand: ItemStackGui
var oldIndex: int = -1

func _ready():
	inv.clear_inventory()
	connectSlots()
	inv.update.connect(update_slots)
	update_slots()
	close()
	

func set_inventory(new_inv: Inv):
	inv = new_inv
	inv.update.connect(update_slots)
	update_slots()


func connectSlots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		slot.inventory = inv
		slot.pressed.connect(Callable(self, "onSlotClicked").bind(slot))
	#for j in get_parent().get_node("TiendaUi/NinePatchRect/GridContainer").get_children():
	#	j.pressed.connect(Callable(get_parent().get_node("TiendaUi/NinePatchRect/GridContainer"), "onSlotClicked").bind(j))
		

func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		var inventorySlot: InvSlot = inv.slots[i]
		
		if !inventorySlot.item: continue
		
		var itemStackGui: ItemStackGui = slots[i].itemStackGui
		if !itemStackGui:
			itemStackGui = ItemStackGuiClass.instantiate()
			slots[i].insert(itemStackGui)
			
		itemStackGui.InventorySlot = inventorySlot
		itemStackGui.update()

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open() 

func open():
	self.visible = true 
	is_open = true

func close():
	visible = false 
	is_open = false

func onSlotClicked_R(slot):
	if slot.isEmpty():
		return
		
	if !itemInHand and slot.itemStackGui.InventorySlot.item != null:
		if slot.itemStackGui.InventorySlot.item.tipo == "alimento":
			get_parent().get_parent().get_node("player").energy += 10
			eraseItem(slot)
			return


func onSlotClicked(slot):
	print(slot.get_parent().get_parent().get_parent().name)
	
	if slot.isEmpty():
		if !itemInHand: return
		insertItemInSlot(slot)
		return
		
	if !itemInHand:
		takeItemFromSlot(slot)
		return
	
	if slot.itemStackGui.InventorySlot.item.nombre == itemInHand.InventorySlot.item.nombre:
		stackItems(slot)
		return
		
	swapItems(slot)

func takeItemFromSlot(slot):
	itemInHand = slot.takeItem()
	add_child(itemInHand)
	updateItemInHand()
	
	oldIndex = slot.index

func insertItemInSlot(slot):
	var item = itemInHand
	remove_child(itemInHand)
	itemInHand = null
	slot.insert(item)
	oldIndex = -1

func swapItems(slot):
	var tempItem = slot.takeItem()
	
	insertItemInSlot(slot)
	itemInHand = tempItem
	add_child(itemInHand)
	updateItemInHand()

func eraseItem(slot):
	var index = slots.find(slot)
	var slotItem: ItemStackGui = slot.itemStackGui
	slotItem.InventorySlot.amount -= 1
	if slotItem.InventorySlot.amount == 0:
		slots[index].itemStackGui.InventorySlot.item = null
		slots[index].itemStackGui.InventorySlot.item = objectData.new() 
	slotItem.update()


func stackItems(slot):
	var slotItem: ItemStackGui = slot.itemStackGui
	var maxAmount = slotItem.InventorySlot.item.StackSize
	var totalAmount = slotItem.InventorySlot.amount + itemInHand.InventorySlot.amount
	
	if slotItem.InventorySlot.amount == maxAmount:
		swapItems(slot)
		return
		
	if totalAmount <= maxAmount:
		slotItem.InventorySlot.amount = totalAmount
		remove_child(itemInHand)
		itemInHand = null
		oldIndex = -1
	else:
		slotItem.InventorySlot.amount = maxAmount
		itemInHand.InventorySlot.amount = totalAmount - maxAmount
		
	slotItem.update()
	if itemInHand: itemInHand.update()
	
func updateItemInHand():
	if !itemInHand: return
	itemInHand.global_position = get_global_mouse_position() - itemInHand.size / 2

func putItemBack():
	if not itemInHand:
		print("no item")
		return
	var player_node = get_tree().get_first_node_in_group("player")
	if not player_node:
		print("no player")
		return
	
	var item_data_to_drop = itemInHand.InventorySlot.item
	var amount_to_drop = itemInHand.InventorySlot.amount
	
	inv.drop_loose_item(item_data_to_drop, amount_to_drop, player_node.global_position)
	remove_child(itemInHand)
	itemInHand.queue_free()
	itemInHand = null # Asegúrate de limpiar la referencia
	oldIndex = -1 # Reseteamos el índice antiguo

func _input(event: InputEvent) -> void:
	if itemInHand && Input.is_action_just_pressed("rightClick"):
		putItemBack()
	updateItemInHand()
	

func removeItemInHandFromInventory():
	if itemInHand:
		inv.removeSlot(itemInHand.InventorySlot)
		update_slots()
