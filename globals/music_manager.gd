extends Node

var _players: Array[AudioStreamPlayer] = []
var _active: int = 0
var _last_pos: float = 0.0
var _current_track: String = ""

var _pending_scene: String = ""
var _pending_packed: PackedScene = null
var _pending_track: String = ""
var _pending_carry: bool = false
var _target_section: int = -1

const BEATS_PER_SECTION: int = 8  # 2 bars of 4/4

var tracks: Dictionary = {
	"title": preload("res://rendered-music/title.wav"),
	"bar": preload("res://rendered-music/bar.wav"),
	"forage": preload("res://rendered-music/forage.wav"),
	"forage_solo": preload("res://rendered-music/forage_solo.wav"),
	"forage_alt": preload("res://rendered-music/forage_alt.wav"),
}

# Cycle: 3x forage, then 1x solo or alt
var _forage_loop_count: int = 0
var _forage_variants: Array[String] = ["forage_solo", "forage_alt"]

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
	if track_name == "forage":
		_forage_loop_count = 0
	BeatClock.sync_to_audio(player)

func _switch_track(track_name: String) -> void:
	var prev = _active
	_active = 1 - _active
	_players[prev].stop()
	var player = _get_active_player()
	player.stream = tracks[track_name]
	player.play()
	_current_track = track_name
	_last_pos = 0.0
	BeatClock.sync_to_audio(player)

func transition_at_loop_end(scene_path: String, track_name: String, carry: bool = false) -> void:
	_pending_scene = scene_path
	_pending_packed = load(scene_path)
	_pending_track = track_name
	_pending_carry = carry

	GameState.prev_phase = GameState.phase
	if scene_path.get_basename().ends_with("tavern"):
		GameState.phase = "bar"
	elif scene_path.get_basename().ends_with("overworld"):
		GameState.phase = "overworld"
	
	# Compute target section: next 2-bar boundary, but if less than 1 bar away, skip to the one after
	var pos = _get_active_player().get_playback_position()
	var secs_per_beat = 60.0 / BeatClock.bpm
	var secs_per_section = secs_per_beat * BEATS_PER_SECTION
	var secs_per_bar = secs_per_beat * 4
	var current_section = int(pos / secs_per_section)
	var time_to_next = (current_section + 1) * secs_per_section - pos
	if time_to_next < secs_per_bar:
		_target_section = current_section + 2
	else:
		_target_section = current_section + 1

func _process(_delta: float) -> void:
	var player = _get_active_player()
	if not player.playing:
		return
	var pos = player.get_playback_position()

	if _pending_scene != "":
		var secs_per_beat = 60.0 / BeatClock.bpm
		var secs_per_section = secs_per_beat * BEATS_PER_SECTION
		var section = int(pos / secs_per_section)
		if section >= _target_section or pos < _last_pos - 1.0:
			var scene = _pending_scene
			var track = _pending_track
			var packed = _pending_packed
			_pending_scene = ""
			_pending_packed = null
			_pending_track = ""
			_pending_carry = false
			_target_section = -1
			play_track(track)
			get_tree().change_scene_to_packed(packed)

	# Detect loop wrap for forage cycling
	if pos < _last_pos - 1.0 and _pending_scene == "":
		if _current_track in ["forage", "forage_solo", "forage_alt"]:
			_forage_loop_count += 1
			if _forage_loop_count >= 3:
				_forage_loop_count = 0
				var variant = _forage_variants[randi() % _forage_variants.size()]
				_switch_track(variant)
			elif _current_track != "forage":
				_switch_track("forage")

	_last_pos = pos
