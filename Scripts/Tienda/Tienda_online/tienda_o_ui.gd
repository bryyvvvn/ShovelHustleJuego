extends Control

@onready var slots := $NinePatchRect/ScrollContainer/VBoxContainer/GridContainer.get_children()
@onready var ItemStackGuiClass = preload("res://Scenes/Inventario/itemsStackGui.tscn")
@export var objects_scene : PackedScene

# Referencia al inventario del jugador (para leer itemInHand)

var itemInHand: ItemStackGui

var cerrado : bool = true



func _ready() -> void:
	visible = false

	for slot in slots:
		slot.pressed.connect(Callable(self, "onSlotClicked").bind(slot))



func accionar() -> void:
	if cerrado:
		open()
		get_parent().get_parent().get_node("player").enable_to_open = false
		get_parent().get_node("inventory").open()
		
	elif !cerrado:
		close()
		get_parent().get_parent().get_node("player").enable_to_open = true
		get_parent().get_node("inventory").close()



func open():
	visible = true
	cerrado = false

func close():
	visible = false 
	cerrado = true

func onSlotClicked(slot):
	
	if not slot.venta:
		if get_parent().get_parent().get_node("player").money >= slot.object_data.get_precio():
			var object = objects_scene.instantiate()
			object.data = slot.object_data
			object.get_node("Sprite2D").texture = slot.object_data.get_texture()
			object.global_position = get_parent().get_parent().get_node("player").global_position
			get_parent().get_parent().add_child(object)
			get_parent().get_parent().get_node("player").money += -slot.object_data.get_precio()
		
		
	else:
		
		var player_inventory_ui := get_parent().get_node("inventory")
		itemInHand = player_inventory_ui.itemInHand
		if itemInHand == null:
			return

		Vfx.play_sfx(0)
		var precio = itemInHand.InventorySlot.item.valor
		var cantidad = itemInHand.InventorySlot.amount
		get_parent().get_parent().get_node("player").update_money(precio * cantidad)

		if slot.isEmpty():
			slot.insert(itemInHand)  # Este ya destruye el item
			player_inventory_ui.itemInHand = null
			player_inventory_ui.oldIndex = -1
