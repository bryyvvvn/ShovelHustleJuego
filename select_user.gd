extends Control
@onready var invite := $Panel/VBoxContainer/invite
@onready var input_message: LineEdit = $Panel/VBoxContainer/HBoxContainer/LineEdit
@onready var send_button: Button = $Panel/VBoxContainer/HBoxContainer/enviar
@onready var cancelar := $Panel/VBoxContainer/cancelar


var online = WebSocketClient
var thename = ""
var userId = ""
var theirstatus = ""

func _ready() -> void:
	online.message_received.connect(_on_message_received)

func setup(username : String,target : String, status : String) -> void:
	var user := $Panel/VBoxContainer/Label
	user.text = "Nombre: %s\nId: %s" % [username, target]
	thename = username
	userId = target
	theirstatus = status
	
func _on_message_received(message: String):
	var msg = JSON.parse_string(message)
	print("Mensaje recibido:", message)
	match msg.event:
		"match-accepted":
			hide()
		"match-rejected":
			var btn = $Panel/VBoxContainer.get_node("cancelarMatch")
			if btn:
				btn.queue_free()
			hide()
	
func _on_invite_pressed() -> void:
	var msg = {
		"event": "send-match-request",
		"data": {
			"playerId": userId,
 		 }
	}
	online.send(JSON.stringify(msg))
	# botón pa cancelar
	var cancel_button := Button.new()
	cancel_button.text = "CANCELAR SOLICITUD"
	cancel_button.name = "cancelarMatch"  
	cancel_button.pressed.connect(_on_cancel_request_pressed)
	$Panel/VBoxContainer.add_child(cancel_button)

func _on_cancel_request_pressed() -> void:
	var cancel_msg = {
		"event": "cancel-match-request",
	}
	online.send(JSON.stringify(cancel_msg))
	var btn = $Panel/VBoxContainer.get_node("cancelarMatch")
	if btn:
		btn.queue_free()

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
