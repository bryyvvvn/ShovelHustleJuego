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
			pingMatch()
		"match-start":
			get_parent().time_elapsed = 0
		"receive-game-data":
			receiveData(msg.data)
		"finish-game":
			if msg.status == "OK":
				get_parent().win()
		"game-ended":
			get_parent().lose()
		"close-match":
			get_parent().queue_free()


func receiveData(datos):
	if datos.has("defeat"):
		var msg = {
			"event": "finish-game"
		}
		_client.send(JSON.stringify(msg))
	if datos.has("rocket"):
		get_parent().player.energy -= datos["rocket"]
	if datos.has("HP"):
		get_parent().get_node("UI/enemy").set_energy(datos["HP"])

func attack():
	var msg = {
		"event" : "send-game-data",
		"data" : {
			"rocket" : 30
		}
	}
	_client.send(JSON.stringify(msg))

func sendHP(hp : float):
	var msg = {
		"event" : "send-game-data",
		"data" : {
			"HP" : hp
		}
	}
	_client.send(JSON.stringify(msg))


func sendDefeat():
	var msg = {
		"event" : "send-game-data",
		"data" : {
			"defeat" : true
		}
	}
	_client.send(JSON.stringify(msg))

func connectMatch():
	var msg = {
		"event" : "connect-match"
	}
	_client.send(JSON.stringify(msg))
	
func pingMatch():
	var msg = {
		"event" : "ping-match"
	}
	_client.send(JSON.stringify(msg))

func quitMatch():
	var msg = {
		"event" : "quit-match"
	}
	_client.send(JSON.stringify(msg))


func _sendGetUserListEvent():
	var dataToSend = {
		"event": 'get-connected-players'
	}
	_client.send(JSON.stringify(dataToSend))
