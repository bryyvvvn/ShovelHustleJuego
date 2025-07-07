extends Node

@onready var player = $AudioStreamPlayer
@onready var song_player = $RandomPlayer
var timer 
var continuar : bool
var current_db : float

var tracks = [
	preload("res://Assets/Sonidos/Background Music/Shovel Hustle Menu.wav"),
	preload("res://Assets/Sonidos/Background Music/desert_background.mp3")
]

var song = [
	preload("res://Assets/Sonidos/Background Music/dream.wav"),
	preload("res://Assets/Sonidos/Background Music/dunes.wav"),
	preload("res://Assets/Sonidos/Background Music/serene.wav"),
	preload("res://Assets/Sonidos/Background Music/arabic.wav")
]

func _ready():
	timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer)

func play_track(index: int):
	continuar = true
	var tween = create_tween()
	tween.tween_property(player, "volume_db", current_db, 2.0)
	if index >= 0 and index < tracks.size():
		player.stream = tracks[index]
		player.play()
	else:
		print("Índice de música fuera de rango.")
	while continuar:
		await player.finished
		player.play()

func stop_music():
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80, 2.0)
	continuar = false
	player.stop()
	timer.stop()

func stop_song():
	var tween = create_tween()
	tween.tween_property(song_player, "volume_db", current_db, 2.0)
	song_player.stop()

func change_volume(db: float):
	current_db = db
	player.volume_db = current_db

func is_playing() -> bool:
	return player.playing

func _on_timer_timeout():
	var tween = create_tween()
	song_player.stream = song.pick_random()
	song_player.volume_db = -80
	song_player.play()
	tween.tween_property(song_player, "volume_db", current_db, 2.0)
	_schedule_next()

func _schedule_next():
	var wait_time = randi_range(90, 580) 
	timer.start(wait_time)

func start_random_music():
	_schedule_next()
