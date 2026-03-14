extends Area2D

signal fruit_collected(fruit_type)

@export var fruit_type: String = "BasketBulb"
@export var bounds_top_left = Vector2.ZERO
@export var bounds_bottom_right = Vector2(DisplayServer.window_get_size())

var _is_moving = false

func _on_body_entered(body):
	emit_signal("fruit_collected", fruit_type)
	Inventory.add_fruit(fruit_type)
	# Remove the element from memory
	queue_free()
	
func in_bounds(target_pos: Vector2) -> bool:
	return (target_pos.x < bounds_bottom_right.x and target_pos.y < bounds_bottom_right.y) \
			and (target_pos.x > bounds_top_left.x and target_pos.y > bounds_top_left.y)

func will_fruit_collide(ray: RayCast2D, target_dir: Vector2):
	ray.target_position = target_dir
	ray.force_raycast_update()
	
	return ray.is_colliding()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# position = TileMovementManager._snap_to_grid(position)
	body_entered.connect(_on_body_entered)
	BeatClock.beat.connect(_on_beat)
	
func get_random_dir() -> Vector2:
	var rand_dir = randi() % 4
	var dir = Vector2.ZERO
	
	match rand_dir:
		0:
			dir.x = 1
		1:
			dir.x = -1
		2:
			dir.y = 1
		3:
			dir.y = -1
		_:
			print_debug("Somethign terrible is happening")
	
	return dir

func _on_beat() -> void:
	if _is_moving:
		return
		
	var ray = $CollisionPredictor
	
	var dir = get_random_dir() * Global.OVERWORLD_TILE_SIZE
	var target_pos = position + Vector2(dir)
	
	var uh_oh = 0
	while not in_bounds(target_pos) or will_fruit_collide(ray, dir):
		if uh_oh > 1000:
			break
			
		uh_oh += 1
		
		dir = get_random_dir()
		target_pos = position + Vector2(dir * Global.OVERWORLD_TILE_SIZE)
		
	if (uh_oh >= 1000):
		print_debug("uhoh")
	
	_is_moving = true
	var duration: float = (60.0 / maxf(BeatClock.bpm, 1.0)) * TileMovementManager.tween_fraction
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished() -> void:
	_is_moving = false
