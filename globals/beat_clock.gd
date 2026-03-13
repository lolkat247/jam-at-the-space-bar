extends Node

signal beat

@export var bpm: float = 140.0

var _audio_player: AudioStreamPlayer = null
var _last_beat_index: int = -1
var _delta_accum: float = 0.0

func sync_to_audio(player: AudioStreamPlayer) -> void:
	_audio_player = player
	_last_beat_index = -1

func _process(delta: float) -> void:
	if bpm == 0.0:
		return
	var secs_per_beat: float = 60.0 / bpm
	var beat_index: int

	if _audio_player and _audio_player.playing:
		var pos = _audio_player.get_playback_position()
		beat_index = int(pos / secs_per_beat)
	else:
		_delta_accum += delta
		beat_index = int(_delta_accum / secs_per_beat)

	if beat_index != _last_beat_index:
		_last_beat_index = beat_index
		beat.emit()

func get_beat_phase() -> float:
	if bpm == 0.0:
		return 0.0
	var secs_per_beat: float = 60.0 / bpm
	if _audio_player and _audio_player.playing:
		var pos = _audio_player.get_playback_position()
		return fmod(pos, secs_per_beat) / secs_per_beat
	return fmod(_delta_accum, secs_per_beat) / secs_per_beat
