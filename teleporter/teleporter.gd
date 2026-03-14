extends Area2D

@export_file("*.tscn") var target_scene: String = ""
@export var target_track: String = ""

var _shaking: bool = false
var _shake_start: float = 0.0
var _player: Node2D
var _player_base_pos: Vector2

var _base_scale: Vector2
var _glow_time: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_base_scale = $Sprite2D.scale
	BeatClock.beat.connect(_on_beat)


func _on_beat() -> void:
	if _shaking:
		return
	var tween := create_tween()
	tween.tween_property($Sprite2D, "scale", _base_scale * 1.12, 0.15)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Sprite2D, "scale", _base_scale, 0.5)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not _shaking:
		_shaking = true
		_shake_start = Time.get_ticks_msec() / 1000.0
		_player = body
		body.position = global_position + Vector2(0, -35)
		body._queued_direction = Vector2i.ZERO
		body.set_process(false)
		body.set_physics_process(false)
		_player_base_pos = body.position
		MusicManager.transition_at_loop_end(target_scene, target_track)


func _process(delta: float) -> void:
	_glow_time += delta
	var glow_alpha = 0.15 + 0.15 * sin(_glow_time * 1.0)
	$Glow.modulate = Color(0.5, 0.85, 1.0, glow_alpha)

	if _shaking:
		var elapsed = Time.get_ticks_msec() / 1000.0 - _shake_start
		var intensity = min(elapsed * 3.0, 20.0)
		_player.position = _player_base_pos + Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
