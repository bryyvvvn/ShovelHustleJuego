extends CharacterBody2D

@export var inv: Inv
@export var speed := 100.0
@export var tienda_scene : PackedScene

var tienda
var game_scene : Node2D

var block_zoom = false
var enable_to_open := true
var is_active := true
var money := 1000
var energy := 100.0
var max_energy := 100.0
var can_sleep := false
var is_in_bed:= false


func erase_energy():
	energy -= 8

func res_energy():
	energy = max_energy



func _ready():
	
	$Camera2D.zoom = Vector2(1, 1) 

var last_direction := Vector2.DOWN #la última dirección que tuvo el personaje (para play idle animations)

func direccion() -> Vector2:
	var direction := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	return direction




func _physics_process(delta):


	if(can_sleep):
		if Input.is_action_just_pressed("tienda"):
			if !is_in_bed:
				is_in_bed = true
			else:
				is_in_bed = true



	if !is_active: #bloqueo de movimiento cuando minigame lod esactive
		return
	var direction = direccion()
	if direction != Vector2.ZERO:
		if !Vfx.is_playing_vfx():
			Vfx.play_vfx(0)
		
		direction = direction.normalized()  # Diagonal speed fix
		velocity = direction * speed
		move_and_slide()
		
		last_direction = direction
		
		
		
		if abs(direction.x) > abs(direction.y):
			$AnimatedSprite2D.animation = "walk_right" if direction.x > 0 else "walk_left"
		else:
			$AnimatedSprite2D.animation = "walk_down" if direction.y > 0 else "walk_up"
		
		
	else:
		if Vfx.is_playing_vfx():
			Vfx.stop_vfx()
		
		velocity = Vector2.ZERO
		
		if abs(last_direction.x) > abs(last_direction.y):
			$AnimatedSprite2D.animation = "idle_right" if last_direction.x > 0 else "idle_left"
		else:
			$AnimatedSprite2D.animation = "idle_down" if last_direction.y > 0 else "idle_up"
	$AnimatedSprite2D.play()
	
	if Input.is_action_just_pressed("zoom_in") and !block_zoom:
		$Camera2D.zoom *= 1.1
	elif Input.is_action_just_pressed("zoom_out") and !block_zoom:
		$Camera2D.zoom *= 0.9
	
	$Camera2D.zoom.x = clamp($Camera2D.zoom.x, -1, 3)
	$Camera2D.zoom.y = clamp($Camera2D.zoom.y, -1, 3)



func player():
	pass



func collect(item):
	Vfx.play_sfx(1)
	inv.insert(item)
	
	
	
func update_money(in_money: int)->void:
	money += in_money
	
	
	
# --- FUNCIÓN QUE SE LLAMA CUANDO UN ÍTEM ES "SOLTADO" DEL INVENTARIO ---
func _on_item_dropped(item_data: objectData, amount: int, drop_position: Vector2): # <--- ¡drop_position es Vector2!
	# Esta función es la que recibe la señal del inventario
	
	if item_data and item_data.item_scene: # Verifica que los datos del ítem y su escena física existan
		for i in range(amount): # Instancia múltiples ítems si la cantidad es mayor a 1
			var dropped_item_instance = item_data.item_scene.instantiate()
			
			# Posiciona el ítem en el mundo
			# Añade un pequeño offset aleatorio para que los ítems no aparezcan exactamente en el mismo punto
			var offset_x = randf_range(-8, 8) # Rango de offset en X
			var offset_y = randf_range(-8, 8) # Rango de offset en Y
			dropped_item_instance.global_position = drop_position + Vector2(offset_x, offset_y)
				
				# Añade el ítem a la escena.
				# Asumiendo que tu jugador es un hijo de la escena principal (ej. el nivel o el mundo del juego).
				# Si tienes un nodo específico para organizar los ítems en tu escena (ej. un nodo "Items" bajo la raíz),
				# entonces usarías ese nodo: get_node("Items").add_child(dropped_item_instance)
			get_parent().add_child(dropped_item_instance) 
				
				# Opcional: Si el script de tu nodo de ítem físico necesita saber la cantidad (ej. para un contador visual)
				# if dropped_item_instance.has_method("set_amount"):
				#    dropped_item_instance.set_amount(1) # Cada instancia física representa una unidad

			print("Player: Instanciado '%s' x %d en la posición %s" % [item_data.nombre, 1, dropped_item_instance.global_position])
	else:
		printerr("Player: ERROR: No se pudo soltar el ítem. Datos del ítem o 'item_scene' inválidos para '%s'." % item_data.nombre if item_data else "Unknown Item")
