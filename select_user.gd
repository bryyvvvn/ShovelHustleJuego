extends Control
@onready var invite := $Panel/VBoxContainer/invite
@onready var chat := $Panel/VBoxContainer/chat
@onready var user := $Panel/VBoxContainer/Label

var online = WebSocketClient

func _ready() -> void:
	pass

func setup(text : String) -> void:
	user.text = text
