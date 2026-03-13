extends Node

# Held items — one slot, up to 3 of the same item
var held_item: String = ""
var held_count: int = 0
const MAX_HELD: int = 3

# Customer state
var current_order: Dictionary = {}
var satisfied_customers: int = 0
var unsatisfied_customers: int = 0

# Score
var score: int = 0

# Game phase: "bar", "overworld", "paused"
var phase: String = "bar"
var _phase_before_pause: String = ""


func pick_up(item_name: String) -> bool:
	if held_item == "" or held_item == item_name:
		if held_count < MAX_HELD:
			held_item = item_name
			held_count += 1
			add_score()
			return true
	return false


func drop_one() -> String:
	if held_count <= 0:
		return ""
	var item = held_item
	held_count -= 1
	if held_count <= 0:
		held_item = ""
	return item


func drop_all() -> void:
	held_item = ""
	held_count = 0


func craft_jam(fruit_name: String, jam_name: String) -> bool:
	if held_item == fruit_name and held_count >= 3:
		drop_all()
		held_item = jam_name
		held_count = 1
		add_score()
		return true
	return false


func serve_jam() -> bool:
	if held_item == "" or current_order.is_empty():
		return false
	if held_item == current_order.get("jam", ""):
		satisfied_customers += 1
		add_score()
		drop_one()
		return true
	else:
		unsatisfied_customers += 1
		drop_one()
		return false


func add_score(points: int = 10) -> void:
	score += points


func pause() -> void:
	_phase_before_pause = phase
	phase = "paused"


func unpause() -> void:
	phase = _phase_before_pause
	_phase_before_pause = ""


func reset() -> void:
	held_item = ""
	held_count = 0
	current_order = {}
	satisfied_customers = 0
	unsatisfied_customers = 0
	score = 0
	phase = "bar"
	_phase_before_pause = ""
