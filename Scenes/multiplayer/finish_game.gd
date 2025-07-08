extends Control
@onready var result: Label = $result
@onready var request: Label = $request
var online = WebSocketClient


func _ready() -> void:
	online.message_received.connect(_on_message_received)

func setup(theresult : String):
	result.text = theresult

func _on_message_received(message: String):
	var msg = JSON.parse_string(message)
	print("Mensaje recibido:", message)
	match msg.event:
		"rematch-request":
			request.show()
		"close-match":
			queue_free()
	#		pass #cuando se salen, hacer q salga que el otro jugador abandonó en pequeño popup (es el mismo que para el juego normal) probablemente 
			#esto se puede manejar desde el mismo multiplayer; finish_game es escena sobrepuesta escondida. al volver al menu multiplayer
			#cierran ambas escenas y se puede manejar con el mismo warning popup.
		"players-ready":
			get_parent().reload_current_scene()
			queue_free() #aquí agregar código para, en paralelo con multiplayer, aquí cerrar con hide() y allá manejar un reinicio de partida con get_tree().reload_current_scene()
		

func _on_salir_pressed() -> void:
	var msg = {
		"event" : "quit-match",
	}
	online.send(JSON.stringify(msg))
	get_tree().change_scene_to_file("res://Scripts/Menú/multiplayermenu.gd")


func _on_rematch_pressed() -> void:
	var msg = {
		"event" : "send-rematch-request",
	}
	online.send(JSON.stringify(msg))
