#Global inventory singleton for fruit counts
extends Node

# Emitted whenever the inventory changes, e.g. when fruit is added or removed.
# This can later be used by HUD / UI elements to update automatically.
signal inventory_changed

# Tracks how many of each fruit type the player currently has.
# For now there is only one fruit type, but this is set up to allow more later.
var fruit_counts: Dictionary[String, int] = {
	"basketbulb": 0
}

func add_fruit(fruit_type: String, amount: int = 1) -> bool:
	# If the fruit type is not in the inventory dictionary, reject it.
	if not fruit_counts.has(fruit_type):
		push_error("Unknown fruit type: %s. Valid fruit types: %s" % [fruit_type, fruit_counts.keys()])
		return false
	
	# Increase the count for the given fruit type.
	fruit_counts[fruit_type] += amount
	
	# Notify anything listening that the inventory changed.
	inventory_changed.emit()
	return true

func get_fruit_count(fruit_type: String) -> int:
	# If the fruit type is not in the inventory dictionary, return 0 and warn.
	if not fruit_counts.has(fruit_type):
		push_error("Unknown fruit type: %s. Valid fruit types: %s" % [fruit_type, fruit_counts.keys()])
		return 0
	
	# Return the current count for that fruit type.
	return fruit_counts[fruit_type]

func has_fruit(fruit_type: String, amount: int = 1) -> bool:
	# If the fruit type is not in the inventory dictionary, reject it.
	if not fruit_counts.has(fruit_type):
		push_error("Unknown fruit type: %s. Valid fruit types: %s" % [fruit_type, fruit_counts.keys()])
		return false
	
	# Returns true if the player has at least the requested amount.
	return fruit_counts[fruit_type] >= amount

func remove_fruit(fruit_type: String, amount: int = 1) -> bool:
	# If the fruit type is not in the inventory dictionary, reject it.
	if not fruit_counts.has(fruit_type):
		push_error("Unknown fruit type: %s. Valid fruit types: %s" % [fruit_type, fruit_counts.keys()])
		return false
	
	# Prevent removing more fruit than the player currently has.
	if fruit_counts[fruit_type] < amount:
		push_error("Not enough %s to remove. Have %d, tried to remove %d." % [fruit_type, fruit_counts[fruit_type], amount])
		return false
	
	# Decrease the count for the given fruit type.
	fruit_counts[fruit_type] -= amount
	
	# Notify anything listening that the inventory changed.
	inventory_changed.emit()
	return true
