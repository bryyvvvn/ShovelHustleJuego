extends Control

# URL de conexión

@onready var _client = WebSocketClient


var _host = "ws://ucn-game-server.martux.cl:4010/"
var _my_id = ""

func _ready():
	GlobalSettings.change_displayMode(0)
	var err = _client.connect_to_url(_host)

# Cuando se conecta al servidor
func _on_web_socket_client_connected_to_server():
	_sendGetUserListEvent()

# Gestor de mensajes del servidor
func _on_web_socket_client_message_received(message: String):
	var response = JSON.parse_string(message)
	
	match(response.event):
		"player-disconnected":
			pass



# Envía un mensaje a un usuario o al chat grupal y manda la solicitud al servidor
func _sendMessage(message: String, userId: String = ''):
	var action
	if (userId != ''):
		action = 'send-private-message'
	else:
		action = 'send-public-message'
		
	var dataToSend = {
		"event": action,
		"data": {
			"message": message
		}
	}

	_client.send(JSON.stringify(dataToSend))

# Solicita la lista de usuarios activos al servidor
func _sendGetUserListEvent():
	var dataToSend = {
		"event": 'get-connected-players'
	}
	_client.send(JSON.stringify(dataToSend))
