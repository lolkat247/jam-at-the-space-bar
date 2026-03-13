extends Node

signal inventory_changed

var fruit_counts: Dictionary[String, int] = {
	"basketbulb": 0
}

func add_fruit(fruit_type: String, amount: int = 1) -> bool:
	if not fruit_counts.has(fruit_type):
		push_error("Unknown fruit type: %s. Valid fruit types: %s" % [fruit_type, fruit_counts.keys()])
		return false
	
	fruit_counts[fruit_type] += amount
	inventory_changed.emit()
	return true

func get_fruit_count(fruit_type: String) -> int:
	if not fruit_counts.has(fruit_type):
		push_error("Unknown fruit type: %s. Valid fruit types: %s" % [fruit_type, fruit_counts.keys()])
		return 0
	
	return fruit_counts[fruit_type]

func has_fruit(fruit_type: String, amount: int = 1) -> bool:
	if not fruit_counts.has(fruit_type):
		push_error("Unknown fruit type: %s. Valid fruit types: %s" % [fruit_type, fruit_counts.keys()])
		return false
	
	return fruit_counts[fruit_type] >= amount

func remove_fruit(fruit_type: String, amount: int = 1) -> bool:
	if not fruit_counts.has(fruit_type):
		push_error("Unknown fruit type: %s. Valid fruit types: %s" % [fruit_type, fruit_counts.keys()])
		return false
	
	if fruit_counts[fruit_type] < amount:
		push_error("Not enough %s to remove. Have %d, tried to remove %d." % [fruit_type, fruit_counts[fruit_type], amount])
		return false
	
	fruit_counts[fruit_type] -= amount
	inventory_changed.emit()
	return true
