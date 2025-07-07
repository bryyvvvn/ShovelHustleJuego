extends Control



@onready var _client = WebSocketClient




func _ready():
	_client.message_received.connect(_on_message_received)
	pass

func _on_message_received(message: String):
	var msg = JSON.parse_string(message)
	print("Mensaje recibido:", message)
	match msg.event:
		"players-ready":
			pass
		"match-start":
			pass


func sendDefeat():
	pass

func connectMatch():
	pass
	
func pingMatch():
	pass
	
func requestRematch():
	pass

func quitMatch():
	pass


func _sendGetUserListEvent():
	var dataToSend = {
		"event": 'get-connected-players'
	}
	_client.send(JSON.stringify(dataToSend))
