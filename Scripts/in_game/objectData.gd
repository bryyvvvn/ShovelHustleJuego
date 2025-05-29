extends Resource
class_name objectData

@export var nombre : String
@export var tipo : String
@export var valor : int
@export var rareza : float
@export var descripcion : String
@export var indice : int
@export var texture : Texture2D
@export var texture_inventory : Texture2D
@export var StackSize: int
@export var intervalo: Vector2
@export var sonido: AudioStream
@export var alimentacion: int

func get_texture()->Texture2D:
	return texture
