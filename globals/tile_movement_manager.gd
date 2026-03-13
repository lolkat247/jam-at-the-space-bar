extends Node

static func get_tile_pos(position: Vector2) -> Vector2i:
	return Vector2i(
		roundi(position.x / Global.Global.TILE_SIZE),
		roundi(position.y / Global.TILE_SIZE)
	)


static func _snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		roundf(pos.x / Global.TILE_SIZE) * Global.TILE_SIZE,
		roundf(pos.y / Global.TILE_SIZE) * Global.TILE_SIZE
	)
