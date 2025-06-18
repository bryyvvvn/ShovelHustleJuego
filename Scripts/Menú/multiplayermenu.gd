extends Control

@onready var _client: WebSocketClient = WebSocketClient
@onready var player_list: ItemList = $Panel/VBoxContainer/jugadores
@onready var status_label: Label = $Panel/VBoxContainer/estado

var _host = "ws://ucn-game-server.martux.cl:4010/"
var _my_id = ""

func _ready():
	GlobalSettings.change_displayMode(0)
	_client.connected_to_server.connect(_on_connected)
	_client.connection_closed.connect(_on_disconnected)
	_client.message_received.connect(_on_message_received)

	var err = _client.connect_to_url(_host)
	if err != OK:
		status_label.text = "Conexión fallida."

	player_list.item_activated.connect(_on_player_selected)

func _on_connected():
	status_label.text = "Conectado. Cargando jugadores..."
	_send_get_user_list()

func _on_disconnected():
	status_label.text = "Desconectado del servidor."

func _on_message_received(message: String):
	var msg = JSON.parse_string(message)
	match msg.event:
		"connected-to-server":
			_my_id = msg.data.id  #agregar forma de ponerse nombre
			status_label.text = "Conectado como %s" % _my_id
		"get-connected-players":
			_update_player_list(msg.data)
		"player-connected":
			player_list.add_item(msg.data.id)
		"player-disconnected":
			_remove_player(msg.data.id)
		"match-request-received":
			_show_invite_popup(msg.data.from)
		"match-accepted":
			status_label.text = "Match con %s" % msg.data.opponent
			get_tree().change_scene_to_file("res://scenes/multiplayer/multiplayer.tscn")

func _send_get_user_list():
	var msg = { "event": "get-connected-players" }
	_client.send(JSON.stringify(msg))

func _update_player_list(players: Array):
	player_list.clear()
	for p in players:
		if p != _my_id:
			player_list.add_item(p)

func _remove_player(id: String):
	for i in player_list.item_count:
		if player_list.get_item_text(i) == id:
			player_list.remove_item(i)
			return

func _on_player_selected(index: int):
	var target = player_list.get_item_text(index)
	var msg = {
		"event": "match-invite",
		"data": { "target": target }
	}
	_client.send(JSON.stringify(msg))
	status_label.text = "Sent match invite to %s" % target

func _show_invite_popup(from_id: String):
	var popup = AcceptDialog.new()
	popup.dialog_text = "%s challenged you to a match!" % from_id
	popup.confirmed.connect(func():
		var msg = {
			"event": "match-accepted", #AGREGAR LA REAL INTERACCIÓN. SE ABRE JUEGO Y SE EMPIEZAN A MANDAR MENSAJES CONSTANTEMENTE EN ESTE MISMO FORMATO var msg = { "event" : "ataque.ejemplo" } y data del jugador blabla
			"data": { "opponent": from_id }
		}
		_client.send(JSON.stringify(msg))
	)
	add_child(popup)
	popup.popup_centered()


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/menujugar.tscn")
