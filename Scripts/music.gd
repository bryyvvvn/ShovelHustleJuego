extends Node

@onready var player = $AudioStreamPlayer

var tracks = [
	preload("res://Assets/Sonidos/Background Music/Shovel Hustle Menu.wav"),
	preload("res://Assets/Sonidos/Background Music/desert_background.mp3")
]

func play_track(index: int):
	if index >= 0 and index < tracks.size():
		player.stream = tracks[index]
		player.play()
	else:
		print("Índice de música fuera de rango.")
