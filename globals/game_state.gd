extends Node

var player_last_pos: Vector2 = Vector2.ZERO

# Customer state
# "fruit", "jam", "count", "pos", "facing"
var current_order: Dictionary = {}
var satisfied_customers: int = 0
var unsatisfied_customers: int = 0

var held_jam: String = ""

# Score
var score: int = 0

# Game phase: "bar", "overworld", "paused"
var phase: String = "bar"
var prev_phase: String = ""
var _phase_before_pause: String = ""


func craft_jam(fruit_name: String, jam_name: String) -> bool:
	if not Inventory.has_fruit(fruit_name, 3):
		return false
	Inventory.remove_fruit(fruit_name, 3)
	Inventory.add_jam(jam_name)
	held_jam = jam_name
	add_score()
	return true


func serve_jam() -> bool:
	if held_jam == "" or current_order.is_empty():
		return false
	var jam = held_jam
	held_jam = ""
	if jam == current_order.get("jam", ""):
		satisfied_customers += 1
		add_score()
		current_order = {}
		return true
	else:
		unsatisfied_customers += 1
		current_order = {}
		return false


func trash_jam() -> void:
	held_jam = ""


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
