extends Node

@onready var player = $AudioStreamPlayer
@onready var song_player = $RandomPlayer
var timer 
var continuar : bool

var tracks = [
	preload("res://Assets/Sonidos/Background Music/Shovel Hustle Menu.wav"),
	preload("res://Assets/Sonidos/Background Music/desert_background.mp3")
]

var song = [
	preload("res://Assets/Sonidos/Background Music/dream.wav"),
	preload("res://Assets/Sonidos/Background Music/dunes.wav"),
	preload("res://Assets/Sonidos/Background Music/serene.wav")
]

func _ready():
	
	timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer)

func play_track(index: int):
	continuar = true
	if index >= 0 and index < tracks.size():
		player.stream = tracks[index]
		player.play()
	else:
		print("Índice de música fuera de rango.")
	while continuar:
		await player.finished
		player.play()

func stop_music():
	player.stop()
	timer.stop()
	continuar = false

func stop_song():
	song_player.stop()

func change_volume(db: float):
	player.volume_db = db

func is_playing() -> bool:
	return player.playing

func _on_timer_timeout():
	song_player.stream = song.pick_random()
	song_player.play()
	_schedule_next()

func _schedule_next():
	var wait_time = randi_range(1, 60) 
	timer.start(wait_time)

func start_random_music():
	_schedule_next()
