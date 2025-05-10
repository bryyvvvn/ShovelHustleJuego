
class_name Animations


static func instanciar_animaciones(source_id: int, tile_set: TileSet) -> void:
	
	var source = tile_set.get_source(source_id)
	if source is TileSetAtlasSource:
			print("Es un TileSetAtlasSource")
	else:
		print("No lo es:", source)
		
	var tile_id : Vector2i
	for i in range(18):
		for j in range(3):
			tile_id = Vector2i(j,i)
			print(tile_id)
			source.set_tile_animation_columns(tile_id, 4)  # ← solo 1 columna por fila (1 frame por fila)
			source.set_tile_animation_frames_count(tile_id, 4)
			source.set_tile_animation_separation(tile_id, Vector2i(3, 0))  # ← separación de 3 tiles

			for k in range(0,2):
				source.set_tile_animation_frame_duration(tile_id, k, 1)
