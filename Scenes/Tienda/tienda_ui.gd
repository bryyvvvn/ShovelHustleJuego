extends Control

@onready var slots := $NinePatchRect/GridContainer.get_children()
@onready var ItemStackGuiClass = preload("res://Scenes/Inventario/itemsStackGui.tscn")

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


func _on_slot_pressed(slot):
	
	var player_inventory_ui := get_parent().get_node("Inv_UI")
	var item = player_inventory_ui.itemInHand
	
	if item:
		# BORRAR el objeto como si lo "vendieras"
		
		item.InventorySlot.amount = 0
		item.queue_free()
		
		# Limpiar mano del jugador
		player_inventory_ui.itemInHand = null
		player_inventory_ui.oldIndex = -1
		
func onSlotClicked(slot):
	
	var player_inventory_ui := get_parent().get_node("Inv_UI")
	itemInHand = player_inventory_ui.itemInHand
	if itemInHand == null:
		return
	Vfx.play_sfx(0)
	var precio = itemInHand.InventorySlot.item.valor
	var cantidad = itemInHand.InventorySlot.amount
	get_parent().get_parent().get_node("player").update_money(precio*cantidad)

	if slot.isEmpty():
		if !itemInHand:
			return
		
		slot.insert(itemInHand)  # Este ya destruye el item
		player_inventory_ui.itemInHand = null
		player_inventory_ui.oldIndex = -1
