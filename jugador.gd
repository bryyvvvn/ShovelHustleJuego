extends CharacterBody2D
@export var move_speed_x : float
@export var move_speed_y : float
@onready var animated_sprite = $AnimatedSprite

var is_facing_right = true #para ver si está moviéndose a las derecha y para que mire ahí

func _ready() -> void:
	pass 

func update_animation(press_shift):   #Cambio de animaciones según la acción
	if not velocity.x and not velocity.y :
		animated_sprite.play("idle")
	
	else: 
		if press_shift:
			animated_sprite.play("run")
		else: 
			animated_sprite.play("walk")
		

func flip(): #Para mover la animación según a donde esté caminando el personaje
	if (is_facing_right and velocity[0] < 0) or (not is_facing_right and velocity[0] > 0):
		scale.x *= -1
		is_facing_right = not is_facing_right

func move(press_shift): #Para mover el personaje. Acá están los valores del movimiento
	var shift_multiplier = 1
	if (press_shift): #Si se apreta shift
		shift_multiplier = 1.77
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity.x = direccion[0] * move_speed_x * shift_multiplier
	velocity.y = direccion[1] * move_speed_y * shift_multiplier
	
	

func _physics_process(delta):
	var press_shift = Input.is_key_pressed(KEY_SHIFT)
	move(press_shift)
	flip()
	update_animation(press_shift)
	move_and_slide()
	pass
