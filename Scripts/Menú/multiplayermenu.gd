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
@onready var invitePopup := preload("res://Scenes/Menu/invite_popup.tscn")


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
	show_disconnected_popup()
	
	

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
		"close-match":
			show_disconnected_popup()
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
			var invitado = invitePopup.instantiate()
			invitado.setup(_find_username(msg.data.playerId),msg.data.playerId,msg.data.matchId)
			add_child(invitado)
		"match-accepted":
			status_label.text = "¡MATCH!"
			get_tree().change_scene_to_file("res://scenes/multiplayer/multiplayer.tscn")
		"accept-match":
			status_label.text = "¡MATCH!"
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
		"send-private-message":
			if msg.status == "OK":
				_sendToChatDisplay("(Susurro): %s" % [msg.data.message])
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
	var status = usersInfo[index].status.strip_edges()
	var selectUser = selectUser.instantiate()
	selectUser.setup(username, target,status)
	add_child(selectUser)


func _on_username_pressed() -> void:
	var nameChange = changeName.instantiate()
	add_child(nameChange)  
	
	
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

func _find_username(id : String): 
	for p in usersInfo:
		if p.id == id:
			return p.name
			
func show_disconnected_popup():
	var label := Label.new()
	label.text = "El otro jugador se ha desconectado"
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.modulate.a = 0.85  

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.6)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	label.add_theme_stylebox_override("panel", style)
	label.custom_minimum_size = Vector2(300, 0)

	var panel := PanelContainer.new()
	panel.add_child(label)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.anchor_left = 0.25
	panel.anchor_right = 0.75
	panel.anchor_top = 0.4
	panel.anchor_bottom = 0.6
	panel.offset_left = 0
	panel.offset_top = 0
	panel.offset_right = 0
	panel.offset_bottom = 0
	panel.z_index = 100

	get_tree().current_scene.add_child(panel)
	await get_tree().create_timer(3.0).timeout
	panel.queue_free()
