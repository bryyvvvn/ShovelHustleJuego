extends Control

@onready var _client: WebSocketClient = WebSocketClient
@onready var player_list: ItemList = $Panel/VBoxContainer/jugadores
@onready var status_label: Label = $Panel/VBoxContainer/estado
@onready var chat_display: TextEdit = $Panel/TextEdit
@onready var input_message: LineEdit = $Panel/HBoxContainer/LineEdit
@onready var send_button: Button = $Panel/HBoxContainer/enviar
@onready var desconectarse: Button = $Button
@onready var changeName := preload("res://Scenes/Menu/username.tscn")
@onready var selectUser := preload("res://Scenes/Menu/select_user.tscn")


var usersInfo = []
var _host = "ws://ucn-game-server.martux.cl:4010/?gameId=G&playerName=ElGato"
var _my_id = ""
var _my_name = ""

var unmsg = '{
	"event": "match-request-received",
	"msg": "te invitaron a jugar"
}'
func _ready():
	GlobalSettings.change_displayMode(0)
	_client.connected_to_server.connect(_on_connected)
	_client.connection_closed.connect(_on_disconnected)
	_client.message_received.connect(_on_message_received)

	var err = _client.connect_to_url(_host)
	if err != OK:
		status_label.text = "Conexión fallida."
	player_list.item_activated.connect(_on_player_selected)
	
	
	#_show_invite_popup(unmsg)
func _on_connected():
	var login =	{
  			"event": "login",
 	 		"data": {
				"gameKey": "BMJWU0"
 	 			}
			}
	_client.send(JSON.stringify(login))
	status_label.text = "Conectado. Cargando jugadores..."

func _on_disconnected():
	status_label.text = "Desconectado del servidor."

func _on_message_received(message: String):
	var msg = JSON.parse_string(message)
	print("Mensaje recibido:", message)
	match msg.event:
		"login":
			if msg.status == "OK":
				_send_get_user_list()
		"connected-to-server":
			_my_name = msg.data.name
			_my_id = msg.data.id
			status_label.text = "Conectado como %s" % _my_name
			desconectarse.text = "DESCONECTARSE"
		"change-name":
			_my_name = msg.data.name
			status_label.text = "Conectado como %s" % _my_name
		"online-players":
			if msg.data != null:
				_update_player_list(msg.data)
		"player-connected":
			player_list.add_item(msg.data.name)
			_sendGetUserListEvent()
		"player-disconnected":
			_remove_player(msg.data.name)
		"match-request-received":
			_show_invite_popup(msg)
		"match-accepted":
			status_label.text = "Match con %s" % msg.data.opponent
			get_tree().change_scene_to_file("res://scenes/multiplayer/multiplayer.tscn")
		"send-match-request":
			if msg.status == "OK":
				status_label.text = msg.msg
			else:
				status_label.text = "Ha ocurrido un error"
		"public-message":
			_sendToChatDisplay("%s: %s" % [msg.data.playerName, msg.data.playerMsg])
		"send-public-message":
			if msg.status == "OK":
				_sendToChatDisplay("Yo: " + msg.data.message)
		"private-message":
			_sendToChatDisplay("(Susurro) %s: %s" % [msg.data.playerName, msg.data.playerMsg])
		"player-name-changed": #cuando alguien se cambia el nombre
			_sendGetUserListEvent()
		"player-status-changed":
			_sendGetUserListEvent()

func _send_get_user_list():
	var msg = { "event": "online-players" }
	_client.send(JSON.stringify(msg))

func _update_player_list(players: Array):
	usersInfo.clear()
	
	player_list.clear()
	for p in players:
		if p.id != _my_id:
			var line = "(%s): %s" % [p.status,p.name]
			player_list.add_item(line)
			usersInfo.append(p)

func _remove_player(id: String):
	for i in player_list.item_count:
		if player_list.get_item_text(i) == id:
			player_list.remove_item(i)
			return

func _on_player_selected(index: int):
	var target = usersInfo[index].id.strip_edges() 
	var username = usersInfo[index].name.strip_edges()
	var targetText = "Nombre: %s\nId: %s" % [username, target]
	var selectUser = selectUser.instantiate()
	selectUser.setup(targetText)
	add_child(selectUser)
	
	#var msg = {
	#	"event": "send-match-request",
	#	"data": {
	#		"playerId": target,
 	#	 }
	#}
	status_label.text = "Enviando solicitud..."
	#_client.send(JSON.stringify(msg))


func _show_invite_popup(message: String):
	var mensaje = JSON.parse_string(message)
	var popup = AcceptDialog.new()
	popup.dialog_text = "¿Quieres aceptar la partida?"
	popup.title = "Invitación"
	popup.get_ok_button().text = "Aceptar"
	var cancel_button = Button.new()
	cancel_button.text = "NO"
	popup.dialog_text = mensaje.msg
	popup.confirmed.connect(func():
		var msg = {
			"event": "accept-match"
		}
		_client.send(JSON.stringify(msg))
	)
	cancel_button.pressed.connect(func(): 
		var msg = {
			"event": "reject-match"
			}
		_client.send(JSON.stringify(msg)) 
		)
	popup.add_child(cancel_button)
	add_child(popup)
	popup.popup_centered()

func _on_username_pressed() -> void:
	var nameChange = changeName.instantiate()
	add_child(nameChange)  # Asegúrate que sea un nodo Control para que se muestre en la UI
	
	
func _on_button_pressed() -> void: 
	WebSocketClient.close()
	get_tree().change_scene_to_file("res://Scenes/Menu/menujugar.tscn")

##CONTROLES PARA EL CHAT 

func _on_input_submitted(message:String): 
	if input_message.text == "":
		return
		
	_sendMessage(message)
	input_message.text = ""

func _on_send_pressed():
	if input_message.text == "":
		return

	_sendMessage(input_message.text)
	input_message.text = ""


# Agrega un mensaje en la pantalla de chat
func _sendToChatDisplay(msg):
	print(msg)
	chat_display.text += str(msg) + "\n"

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
		"event": "online-players"
	}
	_client.send(JSON.stringify(dataToSend))
