extends Control
@onready var si: Button = $Panel/VBoxContainer/HBoxContainer/si
@onready var no: Button = $Panel/VBoxContainer/HBoxContainer/no
@onready var cancelar: Button = $Panel/VBoxContainer/cancelar
@onready var pregunta: Label = $Panel/VBoxContainer/aceptar

var online = WebSocketClient
var thename = ""
var userId = ""
var thematch = ""

func _ready() -> void:
	online.message_received.connect(_on_message_received)


func setup(username : String,target : String,matchId : String) -> void:
	var user := $Panel/VBoxContainer/username
	user.text = "Solicitud de partida de %s\n (Id: %s)" % [username, target]
	thename = username
	userId = target
	thematch = matchId

func _on_message_received(message: String):
	var msg = JSON.parse_string(message)
	print("Mensaje recibido:", message)
	match msg.event:
		"match-canceled-by-sender":
			hide()
			
			

func _on_si_pressed() -> void:
	var msg = {
			"event": "accept-match"
		}
	online.send(JSON.stringify(msg))
	pregunta.hide()
	si.hide()
	no.hide()
	cancelar.show()

func _on_no_pressed() -> void:
	var msg = {
			"event": "reject-match"
			}
	online.send(JSON.stringify(msg)) 
	hide()


func _on_cancelar_pressed() -> void:
	var msg = {
		"event": "cancel-match-request"
			}
	online.send(JSON.stringify(msg)) 
	
	hide()
