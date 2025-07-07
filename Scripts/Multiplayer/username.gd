extends Control

@onready var name_input := $Panel/VBoxContainer/LineEdit
@onready var connect_button := $Panel/VBoxContainer/aceptar
var online = WebSocketClient

func _ready():
	pass

func _on_aceptar_pressed() -> void:
	var username = name_input.text.strip_edges()
	if username == "":
		show_alert("Por favor ingresa un nombre válido.")
		return
	else:
		var msg = {
  			"event": "change-name",
  			"data": {
				"name": username
  				}
			}
		online.send(JSON.stringify(msg))
		hide()
	

func show_alert(msg):
	var dialog := AcceptDialog.new()
	dialog.dialog_text = msg
	add_child(dialog)
	dialog.popup_centered()
