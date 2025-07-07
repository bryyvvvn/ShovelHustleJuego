extends Control
@onready var invite := $Panel/VBoxContainer/invite
@onready var input_message: LineEdit = $Panel/VBoxContainer/HBoxContainer/LineEdit
@onready var send_button: Button = $Panel/VBoxContainer/HBoxContainer/enviar
@onready var cancelar := $Panel/VBoxContainer/cancelar


var online = WebSocketClient
var thename = ""
var userId = ""

func _ready() -> void:
	pass

func setup(username : String,target : String) -> void:
	var user := $Panel/VBoxContainer/Label
	user.text = "Nombre: %s\nId: %s" % [username, target]
	thename = username
	userId = target
func _on_invite_pressed() -> void:
	pass # Replace with function body.


func _on_chat_pressed() -> void:
	pass # Replace with function body.


func _on_cancelar_pressed() -> void:
	hide()

func _on_input_submitted(message:String): 
	if input_message.text == "":
		return
		
	_sendPrivMessage(message,userId)
	input_message.text = ""

func _on_send_pressed():
	if input_message.text == "":
		return
	_sendPrivMessage(input_message.text,userId)
	input_message.text = ""
	
func _sendPrivMessage(msg : String,playerId : String):
	var mensaje = {
		"event": "send-private-message",
		"data": {
			"playerId": playerId,
			"message": msg
  			}
		}
	online.send(JSON.stringify(mensaje))
