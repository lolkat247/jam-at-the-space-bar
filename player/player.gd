extends CharacterBody2D

const TILE_SIZE = 32
## How long the slide tween takes, as a fraction of one beat (0.0–1.0).
@export var tween_fraction: float = 0.25

var _queued_direction: Vector2i = Vector2i.ZERO
var _is_moving: bool = false


func _ready() -> void:
	position = _snap_to_grid(position)
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

	var target_pos: Vector2 = position + Vector2(dir * TILE_SIZE)

	# TODO: collision check — depends on tilemap being set up
	# see task "Player — grid movement collision check"

	_is_moving = true
	var duration: float = (60.0 / maxf(BeatClock.bpm, 1.0)) * tween_fraction
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(_on_tween_finished)


func _on_tween_finished() -> void:
	_is_moving = false
	position = _snap_to_grid(position)


func get_tile_pos() -> Vector2i:
	return Vector2i(
		roundi(position.x / TILE_SIZE),
		roundi(position.y / TILE_SIZE)
	)


func _snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		roundf(pos.x / TILE_SIZE) * TILE_SIZE,
		roundf(pos.y / TILE_SIZE) * TILE_SIZE
	)
