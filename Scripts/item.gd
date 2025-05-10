extends Node2D

var item_name : String
var item_quantity : int = 0
var item_data_resource : objectData

@onready var item_texture_rect : TextureRect = $TextureRect
@onready var item_label : Label = $Label

@export var diamante_resource_path : String
@export var plata_resource_path : String

func _ready():
	var rand_val = randi() % 2
	var chosen_resource_path : String
	
	if rand_val == 0:
		item_name = "diamante"
		chosen_resource_path = diamante_resource_path
	else: 
		item_name = "plata"
		chosen_resource_path = plata_resource_path
	
	item_data_resource = load(chosen_resource_path)
	
	if item_data_resource == null:
		print("Error: No se pudo cargar el resource del item desde la ruta: ", chosen_resource_path)
		queue_free() 
		return
	
	item_texture_rect.texture = load("res://Assets/Sprites/objects/" + item_data_resource.nombre.to_lower() + ".png")
	var stack_size : int = item_data_resource.StackSize
	
	if stack_size > 1:
		item_quantity = randi() % stack_size + 1 
	else:
		item_quantity = 1 
	
	if stack_size == 1:
		$Label.visible = false
	else:
		$Label.text = str(item_quantity)
	print("Item aleatorio creado: ", item_data_resource.nombre, " (", item_quantity, "/", stack_size, ")")
	
func add_item_quantity(amount_to_add):
	item_quantity += amount_to_add
	$Label.text = str(item_quantity)

func decrease_item_quantity(amount_to_remove):
	item_quantity -= amount_to_remove
	$Label.text = str(item_quantity)
	
