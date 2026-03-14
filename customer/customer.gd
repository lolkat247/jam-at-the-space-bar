extends CharacterBody2D

var _queued_direction: Vector2i = Vector2i.ZERO
var _is_moving: bool = false
var _move_queue: Array[Vector2i] = [
	Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP,
	Vector2i.LEFT,
]

var _order_shown: bool = false

var _facing_textures := {
	Vector2i.DOWN: preload("res://sprites/toast_customer.png"),
	Vector2i.UP: preload("res://sprites/toast_customer_up.png"),
	Vector2i.LEFT: preload("res://sprites/toast_customer_right.png"),
	Vector2i.RIGHT: preload("res://sprites/toast_customer_left.png"),
}


func _ready() -> void:
	position = TileMovementManager._snap_to_grid(position)
	BeatClock.beat.connect(_on_beat)

	if not GameState.current_order.is_empty():
		position = _compute_final_position()
		_move_queue.clear()
		_order_shown = true
		_set_facing(Vector2i.LEFT)
		$AnimatedSprite2D/OrderBubble.visible = true


func queue_direction(dir: Vector2i) -> void:
	_queued_direction = dir
	_set_facing(dir)


func _set_facing(dir: Vector2i) -> void:
	$AnimatedSprite2D.sprite_frames.set_frame("default", 0, _facing_textures[dir])


func _on_beat() -> void:
	if _queued_direction == Vector2i.ZERO and _move_queue.size() > 0:
		var next_dir = _move_queue.pop_front()
		_queued_direction = next_dir
		_set_facing(next_dir)
	if _queued_direction == Vector2i.ZERO:
		if not _order_shown and _move_queue.size() == 0:
			_show_order()
		return
	if _is_moving:
		return

	var dir := _queued_direction
	_queued_direction = Vector2i.ZERO

	var target_pos: Vector2 = position + Vector2(dir * Global.TILE_SIZE)

	_is_moving = true
	var duration: float = (60.0 / maxf(BeatClock.bpm, 1.0)) * TileMovementManager.tween_fraction
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(_on_tween_finished)


func _on_tween_finished() -> void:
	_is_moving = false


func _compute_final_position() -> Vector2:
	var start := TileMovementManager._snap_to_grid(position)
	var offset := Vector2i.ZERO
	for dir in _move_queue:
		offset += dir
	return start + Vector2(offset * Global.TILE_SIZE)


func _show_order() -> void:
	_order_shown = true
	if GameState.current_order.is_empty():
		GameState.current_order = {
			"fruit": "Basketbulb",
		"jam": "Basketbulb Jam",
			"count": 3,
		}
	$AnimatedSprite2D/OrderBubble.visible = true
