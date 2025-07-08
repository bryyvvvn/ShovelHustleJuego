extends Control
@onready var result: Label = $result
@onready var request: Label = $request
var online = WebSocketClient
 

func _ready() -> void:
	online.message_received.connect(_on_message_received)
	print(result.name)

func setup(theresult : String):
	var resultNode = get_node("result")
	if resultNode:
		resultNode.text = theresult
	else:
		print("Nodo 'result' no encontrado")

func _on_message_received(message: String):
	var msg = JSON.parse_string(message)
	print("Mensaje recibido:", message)
	match msg.event:
		"rematch-request":
			request.show()
		"close-match":
			get_tree().change_scene_to_file("res://Scenes/Menu/multiplayermenu.tscn")
	#		pass #cuando se salen, hacer q salga que el otro jugador abandonó en pequeño popup (es el mismo que para el juego normal) probablemente 
			#esto se puede manejar desde el mismo multiplayer; finish_game es escena sobrepuesta escondida. al volver al menu multiplayer
			#cierran ambas escenas y se puede manejar con el mismo warning popup.
		"players-ready":
			#get_parent().get_node("online").pingMatch()
			#get_tree().change_scene_to_file("res://Scenes/multiplayer/multiplayer.tscn")
			#queue_free() #aquí agregar código para, en paralelo con multiplayer, aquí cerrar con hide() y allá manejar un reinicio de partida con get_tree().reload_current_scene()
			#get_tree().change_scene_to_file("res://Scenes/multiplayer/multiplayer.tscn")
			pass


func _on_salir_pressed() -> void:
	var msg = {
		"event" : "quit-match",
	}
	online.send(JSON.stringify(msg))
	get_tree().change_scene_to_file("res://Scenes/Menu/multiplayermenu.tscn")


func _on_rematch_pressed() -> void:
	var msg = {
		"event" : "send-rematch-request",
	}
	online.send(JSON.stringify(msg))
