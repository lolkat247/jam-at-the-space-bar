extends Node

## How long the slide tween takes, as a fraction of one beat (0.0–1.0).
static var tween_fraction: float = 0.25

static func get_random_tile_pos() -> Vector2i:
	var screen_size = DisplayServer.window_get_size()
	
	var max_tile_x = int(screen_size.x / Global.TILE_SIZE)
	var max_tile_y = int(screen_size.y / Global.TILE_SIZE)
	
	var rand_tile_x = randi() % max_tile_x
	var rand_tile_y = randi() % max_tile_y
	
	return Vector2i(rand_tile_x, rand_tile_y)

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
