extends CharacterBody2D



@export var rapidez := 400
var tile_size = 0




func coordenadas() -> Vector2:
	var dir = Vector2.ZERO

	if Input.is_key_pressed(KEY_W):
		dir.y -= 1
	if Input.is_key_pressed(KEY_S):
		dir.y += 1
	if Input.is_key_pressed(KEY_A):
		dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		dir.x += 1

	return dir.normalized()
	
func _ready() -> void:
	$ColorRect.color = Color.BLACK
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(tile_size/2, tile_size/2)
	
	var col = CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	
func _physics_process(delta: float) -> void:
	velocity = coordenadas() * rapidez
	move_and_slide()
	

	
