extends Control
@onready var invite := $Panel/VBoxContainer/invite
@onready var chat := $Panel/VBoxContainer/chat
@onready var user := $Panel/VBoxContainer/Label

var online = WebSocketClient

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
