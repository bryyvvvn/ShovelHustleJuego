extends Button

@onready var container: CenterContainer = $CenterContainer

var itemStackGui: ItemStackGui
var object_data : objectData = preload("res://Assets/Recursos/Objects/basura.tres")
var venta := false


func _ready():
	var sprite := get_node("Sprite2D")
	sprite.texture = preload("res://Assets/Sprites/objects/objects_32/basura.png")
	sprite.scale = Vector2(0.8, 0.8)

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
