extends CharacterBody2D

var _queued_direction: Vector2i = Vector2i.ZERO
var _is_moving: bool = false

const BEAT_TOLERANCE := 0.30
const PERFECT_THRESHOLD := 0.12
const SHAKE_PIXELS := 12.0
const SHAKE_DURATION := 0.25

var _facing_textures := {
	Vector2i.DOWN: preload("res://sprites/astronaut_chef.png"),
	Vector2i.UP: preload("res://sprites/astronaut_chef_up.png"),
	Vector2i.LEFT: preload("res://sprites/astronaut_chef_left.png"),
	Vector2i.RIGHT: preload("res://sprites/astronaut_chef_right.png"),
}


func _ready() -> void:
	position = TileMovementManager._snap_to_grid(position)


func _process(_delta: float) -> void:
	# Buffer the most recent directional input (last-wins)
	if Input.is_action_pressed("arrow_right"):
		_queued_direction = Vector2i.RIGHT
		_set_facing(Vector2i.RIGHT)
	elif Input.is_action_pressed("arrow_left"):
		_queued_direction = Vector2i.LEFT
		_set_facing(Vector2i.LEFT)
	elif Input.is_action_pressed("arrow_down"):
		_queued_direction = Vector2i.DOWN
		_set_facing(Vector2i.DOWN)
	elif Input.is_action_pressed("arrow_up"):
		_queued_direction = Vector2i.UP
		_set_facing(Vector2i.UP)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("space_press"):
		return
	if _queued_direction == Vector2i.ZERO:
		return
	if _is_moving:
		return

	var phase := BeatClock.get_beat_phase()
	var dist := minf(phase, 1.0 - phase)

	if dist >= BEAT_TOLERANCE:
		_shake()
		return

	# On beat — execute movement
	var dir := _queued_direction
	_queued_direction = Vector2i.ZERO

	var tile_size = Global.TILE_SIZE
	if get_parent() is Node and get_parent().name == "TestOverworld":
		tile_size = Global.OVERWORLD_TILE_SIZE
	var target_pos: Vector2 = position + Vector2(dir * tile_size)

	if dist <= PERFECT_THRESHOLD:
		_on_perfect_hit()
	else:
		_on_good_hit()

	_is_moving = true
	var duration: float = (60.0 / maxf(BeatClock.bpm, 1.0)) * TileMovementManager.tween_fraction
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(_on_tween_finished)


func _set_facing(dir: Vector2i) -> void:
	$AnimatedSprite2D.sprite_frames.set_frame("default", 0, _facing_textures[dir])


func _shake() -> void:
	var original_pos := position
	var tween := create_tween()
	var step_time := SHAKE_DURATION / 6.0
	for i in 3:
		var offset := Vector2(randf_range(-SHAKE_PIXELS, SHAKE_PIXELS), randf_range(-SHAKE_PIXELS, SHAKE_PIXELS))
		tween.tween_property(self, "position", original_pos + offset, step_time)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(self, "position", original_pos, step_time)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position", original_pos, 0.0)


func _on_perfect_hit() -> void:
	pass


func _on_good_hit() -> void:
	pass


func _on_tween_finished() -> void:
	_is_moving = false
