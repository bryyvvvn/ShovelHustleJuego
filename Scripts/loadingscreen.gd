extends Control

@export var next_scene_path := "res://Scenes/game.tscn"

func _ready():
	$AnimatedSprite2D.play("coin")
	call_deferred("_load_scene")
	
func _physics_process(delta: float) -> void:
	$AnimatedSprite2D.play("coin")

func _load_scene():
	ResourceLoader.load_threaded_request(next_scene_path)
	while ResourceLoader.load_threaded_get_status(next_scene_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame 
	
	var scene = ResourceLoader.load_threaded_get(next_scene_path)

	if scene is PackedScene:
		var instance = scene.instantiate()
		get_tree().root.add_child(instance)

		var current = get_tree().current_scene
		if current:
			current.queue_free()

		get_tree().current_scene = instance
		queue_free()
