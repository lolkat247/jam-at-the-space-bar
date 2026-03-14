extends Node

var player_last_pos: Vector2 = Vector2.ZERO

# Customer state
# "fruit", "jam", "count", "pos", "facing"
var current_order: Dictionary = {}
var satisfied_customers: int = 0
var unsatisfied_customers: int = 0

# Score
var score: int = 0

# Game phase: "bar", "overworld", "paused"
var phase: String = "bar"
var prev_phase: String = ""
var _phase_before_pause: String = ""


func add_score(points: int = 10) -> void:
	score += points


func pause() -> void:
	_phase_before_pause = phase
	phase = "paused"


func unpause() -> void:
	phase = _phase_before_pause
	_phase_before_pause = ""


func reset() -> void:
	current_order = {}
	satisfied_customers = 0
	unsatisfied_customers = 0
	score = 0
	phase = "bar"
	_phase_before_pause = ""
