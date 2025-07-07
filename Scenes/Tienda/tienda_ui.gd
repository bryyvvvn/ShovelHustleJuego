extends Control

@onready var slots := $NinePatchRect/ScrollContainer/VBoxContainer/GridContainer.get_children()
@onready var ItemStackGuiClass = preload("res://Scenes/Inventario/itemsStackGui.tscn")
@onready var inventario = get_parent().get_node("inv_ui")
@export var objects_scene : PackedScene

# Referencia al inventario del jugador (para leer itemInHand)

var itemInHand: ItemStackGui

var enabled : bool
var cerrado : bool = true

func _ready() -> void:
	visible = false

	for slot in slots:
		slot.pressed.connect(Callable(self, "onSlotClicked").bind(slot))

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("tienda"): 
		
		if cerrado:
			if enabled:
				open()
		elif !cerrado:
			close()

func open():
	
	visible = true
	cerrado = false

func close():
	visible = false 
	cerrado = true

func onSlotClicked(slot):
	if not slot.venta:
		var object = objects_scene.instantiate()
		object.data = slot.object_data
		object.get_node("Sprite2D").texture = slot.object_data.get_texture()
		object.global_position = get_parent().get_parent().get_node("player").global_position
		get_parent().get_parent().add_child(object)
		get_parent().get_parent().get_node("player").money += -slot.object_data.get_precio()
	else:
		
		var player_inventory_ui := get_parent().get_node("Inv_UI")
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
