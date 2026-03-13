extends Area2D

@export_file("*.tscn") var target_scene: String = ""
@export var target_track: String = ""

var _shaking: bool = false
var _shake_start: float = 0.0
var _player: Node2D
var _player_base_pos: Vector2


func _ready() -> void:
	body_entered.connect(_on_body_entered)


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


func _process(_delta: float) -> void:
	if _shaking:
		var elapsed = Time.get_ticks_msec() / 1000.0 - _shake_start
		var intensity = min(elapsed * 3.0, 20.0)
		_player.position = _player_base_pos + Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
