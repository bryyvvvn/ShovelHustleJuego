extends Node

@onready var player = $AudioStreamPlayer
@onready var player2 = $AudioStreamPlayer2
@onready var player3 = $AudioStreamPlayer3

var mineral = [
	preload("res://Assets/Sonidos/Sonido_minerales/dig_trash.wav"),
	preload("res://Assets/Sonidos/menu_click.wav"),
	preload("res://Assets/Sonidos/Sonido_minerales/stone_dig.wav"),
	preload("res://Assets/Sonidos/Sonido_minerales/coal_dig.wav"),
	preload("res://Assets/Sonidos/Sonido_minerales/iron_dig.wav"),
	preload("res://Assets/Sonidos/Sonido_minerales/silver_dig.wav"),
	preload("res://Assets/Sonidos/Sonido_minerales/gold_dig.wav"),
	preload("res://Assets/Sonidos/Sonido_minerales/diamond_dig.wav")
]

var sounds = [
	preload("res://Assets/Sonidos/menu_click.wav"),
	preload("res://Assets/Sonidos/sand_walking.wav"),
	
]

var sfx = [
	preload("res://Assets/Sonidos/item_sold.wav")
]

func play_mineral(index: int):
	if index >= 0 and index < mineral.size():
		player.pitch_scale = randf_range(0.8, 1.3)
		player.stream = mineral[index]
		player.play()
	else:
		print("Índice de música fuera de rango.")

func play_vfx(index: int):
	if index >= 0 and index < sounds.size():
		player2.pitch_scale = randf_range(0.9, 1.2)
		player2.stream = sounds[index]
		player2.play()
	else:
		print("Índice de música fuera de rango.")

func play_sfx(index: int):
	if index >= 0 and index < sounds.size():
		player3.pitch_scale = randf_range(0.9, 1.2)
		player3.stream = sounds[index]
		player3.play()
	else:
		print("Índice de música fuera de rango.")

func stop_music():
	player.stop()
	
func change_volume(db: float):
	player.volume_db = db
	player2.volume_db = db
	player3.volume_db = db

func is_playing() -> bool:
	if player.playing:
		return true
	else:
		return false
