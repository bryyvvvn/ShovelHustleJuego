extends Control



@onready var _client = WebSocketClient




func _ready():
	_client.message_received.connect(_on_message_received)
	pass

func _on_message_received(message: String):
	var msg = JSON.parse_string(message)
	
	match msg.event:
		"players-ready":
			#_client.connect_to_url("ws://ucn-game-server.martux.cl:4010/?gameId=G&playerName=ElGato")
			pingMatch()
			#get_tree().reload_current_scene()
		"match-start":
			get_parent().time_elapsed = 0
		"receive-game-data":
			receiveData(msg.data)
		"finish-game":
			print("Mensaje recibido:", message)
			if msg.status == "OK":
				get_parent().win()
		"game-ended":
			
			print("Mensaje recibido:", message)
			get_parent().lose()
		"close-match":
			get_tree().change_scene_to_file("res://Scenes/Menu/multiplayermenu.tscn")
			

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
