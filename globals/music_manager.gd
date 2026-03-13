extends Node

var _players: Array[AudioStreamPlayer] = []
var _active: int = 0
var _last_pos: float = 0.0
var _current_track: String = ""

var _pending_scene: String = ""
var _pending_track: String = ""
var _pending_carry: bool = false

var tracks: Dictionary = {
	"title": preload("res://rendered-music/title.wav"),
	"bar": preload("res://rendered-music/bar.wav"),
}

func _ready() -> void:
	for i in 2:
		var p = AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)

func _get_active_player() -> AudioStreamPlayer:
	return _players[_active]

func play_track(track_name: String, from_pos: float = 0.0) -> void:
	if _current_track == track_name and _get_active_player().playing:
		return
	var prev = _active
	_active = 1 - _active
	_players[prev].stop()
	var player = _get_active_player()
	player.stream = tracks[track_name]
	player.play(from_pos)
	_current_track = track_name
	_last_pos = from_pos
	BeatClock.sync_to_audio(player)

func transition_at_loop_end(scene_path: String, track_name: String, carry: bool = false) -> void:
	_pending_scene = scene_path
	_pending_track = track_name
	_pending_carry = carry

func _process(_delta: float) -> void:
	var player = _get_active_player()
	if not player.playing:
		return
	var pos = player.get_playback_position()
	# Detect loop boundary: position wrapped around
	if pos < _last_pos - 1.0:
		if _pending_scene != "":
			var scene = _pending_scene
			var track = _pending_track
			_pending_scene = ""
			_pending_track = ""
			_pending_carry = false
			play_track(track)
			get_tree().change_scene_to_file(scene)
	_last_pos = pos
