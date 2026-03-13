extends Area2D

signal fruit_collected(fruit_type)

@export var fruit_type: String = "BasketBulb"
var _is_moving = false
var tween: Tween

func _on_body_entered(body):
	emit_signal("fruit_collected", fruit_type)
	# Remove the element from memory
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(200, 200)
	pass
	# position = TileMovementManager._snap_to_grid(position)
	body_entered.connect(_on_body_entered)
	BeatClock.beat.connect(_on_beat)

func _on_beat() -> void:
	if _is_moving:
		return
	
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

	var target_pos = position + Vector2(dir * Global.TILE_SIZE)
	
	clamp(target_pos, Vector2.ZERO, Vector2(DisplayServer.window_get_size()))
	
	_is_moving = true
	var duration: float = (60.0 / maxf(BeatClock.bpm, 1.0)) * TileMovementManager.tween_fraction
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished() -> void:
	_is_moving = false
