extends Node2D

func _ready():
	$ColorRect.color = Color(0, 0, 0, 0.5) 

func _physics_process(delta: float) -> void:   
	$ColorRect.color = Color(0, 0, 0, 0.5) 
