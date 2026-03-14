extends Node

## How long the slide tween takes, as a fraction of one beat (0.0–1.0).
static var tween_fraction: float = 0.25

static func get_tile_pos(position: Vector2) -> Vector2i:
	return Vector2i(
		roundi(position.x / Global.TILE_SIZE),
		roundi(position.y / Global.TILE_SIZE)
	)

static func _snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		roundf(pos.x / Global.TILE_SIZE) * Global.TILE_SIZE,
		roundf(pos.y / Global.TILE_SIZE) * Global.TILE_SIZE
	)
