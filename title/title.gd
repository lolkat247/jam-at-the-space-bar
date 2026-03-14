extends Control

var _base_position: Vector2
var _vibrating: bool = false
var _vibrate_start: float = 0.0

func _ready() -> void:
	MusicManager.play_track("title")
	$PlayButton.pressed.connect(_on_play_pressed)
	_base_position = $PlayButton.position


func _on_play_pressed() -> void:
	_vibrating = true
	_vibrate_start = Time.get_ticks_msec() / 1000.0
	$PlayButton.scale = Vector2.ONE
	MusicManager.transition_at_loop_end("res://tavern/tavern.tscn", "bar")
	GameState.phase = "bar"


func _process(_delta: float) -> void:
	if _vibrating:
		var elapsed = Time.get_ticks_msec() / 1000.0 - _vibrate_start
		var intensity = min(elapsed * 3.0, 20.0)
		$PlayButton.position = _base_position + Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		return

	# Pulse every 2 beats using audio-synced phase
	var secs_per_beat = 60.0 / BeatClock.bpm
	var secs_per_pulse = secs_per_beat * 2.0
	var pos = 0.0
	if BeatClock._audio_player and BeatClock._audio_player.playing:
		pos = BeatClock._audio_player.get_playback_position()
	else:
		pos = BeatClock._delta_accum
	var phase = fmod(pos, secs_per_pulse) / secs_per_pulse
	# Sharp attack, smooth decay: 0→1 quickly, then ease back
	var pulse = 1.0 + 0.06 * max(1.0 - phase * 3.0, 0.0)
	$PlayButton.scale = Vector2(pulse, pulse)
