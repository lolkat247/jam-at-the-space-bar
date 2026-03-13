extends CharacterBody2D



var _queued_direction: Vector2i = Vector2i.ZERO
var _is_moving: bool = false


func _ready() -> void:
	position = TileMovementManager._snap_to_grid(position)
	BeatClock.beat.connect(_on_beat)


func _process(_delta: float) -> void:
	# Buffer the most recent directional input (last-wins)
	if Input.is_action_pressed("arrow_right"):
		_queued_direction = Vector2i.RIGHT
	elif Input.is_action_pressed("arrow_left"):
		_queued_direction = Vector2i.LEFT
	elif Input.is_action_pressed("arrow_down"):
		_queued_direction = Vector2i.DOWN
	elif Input.is_action_pressed("arrow_up"):
		_queued_direction = Vector2i.UP


func _on_beat() -> void:
	if _queued_direction == Vector2i.ZERO:
		return
	if _is_moving:
		return

	var dir := _queued_direction
	_queued_direction = Vector2i.ZERO

	var target_pos: Vector2 = position + Vector2(dir * Global.TILE_SIZE)

	# TODO: collision check — depends on tilemap being set up
	# see task "Player — grid movement collision check"

	_is_moving = true
	var duration: float = (60.0 / maxf(BeatClock.bpm, 1.0)) * TileMovementManager.tween_fraction
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(_on_tween_finished)


func _on_tween_finished() -> void:
	_is_moving = false
