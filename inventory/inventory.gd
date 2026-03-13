# Global inventory singleton for fruit and jam counts
extends Node

# Emitted whenever the inventory changes, e.g. when fruit or jam is added or removed.
# This can later be used by HUD / UI elements to update automatically.
signal inventory_changed

# Tracks how many of each fruit type the player currently has.
# For now there is only one fruit type, but this is set up to allow more later.
var fruit_counts: Dictionary[String, int] = {
	"BasketBulb": 0
}

# Tracks how many of each jam type the player currently has.
# For now there is only one jam type, but this is set up to allow more later.
var jam_counts: Dictionary[String, int] = {
	"BasketBulb Jam": 0
}

func add_fruit(fruit_type: String, amount: int = 1) -> bool:
	# Reject unknown fruit types.
	if not fruit_counts.has(fruit_type):
		push_error("Unknown fruit type: %s. Valid fruit types: %s" % [fruit_type, fruit_counts.keys()])
		return false
	
	# Reject invalid amounts.
	if amount < 1:
		push_error("add_fruit amount must be at least 1. Got %d." % amount)
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
	# Reject unknown fruit types.
	if not fruit_counts.has(fruit_type):
		push_error("Unknown fruit type: %s. Valid fruit types: %s" % [fruit_type, fruit_counts.keys()])
		return false
	
	# Reject invalid amounts.
	if amount < 1:
		push_error("has_fruit amount must be at least 1. Got %d." % amount)
		return false
	
	# Returns true if the player has at least the requested amount.
	return fruit_counts[fruit_type] >= amount

func remove_fruit(fruit_type: String, amount: int = 1) -> bool:
	# Reject unknown fruit types.
	if not fruit_counts.has(fruit_type):
		push_error("Unknown fruit type: %s. Valid fruit types: %s" % [fruit_type, fruit_counts.keys()])
		return false
	
	# Reject invalid amounts.
	if amount < 1:
		push_error("remove_fruit amount must be at least 1. Got %d." % amount)
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

func add_jam(jam_type: String, amount: int = 1) -> bool:
	# Reject unknown jam types.
	if not jam_counts.has(jam_type):
		push_error("Unknown jam type: %s. Valid jam types: %s" % [jam_type, jam_counts.keys()])
		return false
	
	# Reject invalid amounts.
	if amount < 1:
		push_error("add_jam amount must be at least 1. Got %d." % amount)
		return false
	
	# Increase the count for the given jam type.
	jam_counts[jam_type] += amount
	
	# Notify anything listening that the inventory changed.
	inventory_changed.emit()
	return true

func get_jam_count(jam_type: String) -> int:
	# If the jam type is not in the inventory dictionary, return 0 and warn.
	if not jam_counts.has(jam_type):
		push_error("Unknown jam type: %s. Valid jam types: %s" % [jam_type, jam_counts.keys()])
		return 0
	
	# Return the current count for that jam type.
	return jam_counts[jam_type]

func has_jam(jam_type: String, amount: int = 1) -> bool:
	# Reject unknown jam types.
	if not jam_counts.has(jam_type):
		push_error("Unknown jam type: %s. Valid jam types: %s" % [jam_type, jam_counts.keys()])
		return false
	
	# Reject invalid amounts.
	if amount < 1:
		push_error("has_jam amount must be at least 1. Got %d." % amount)
		return false
	
	# Returns true if the player has at least the requested amount.
	return jam_counts[jam_type] >= amount

func remove_jam(jam_type: String, amount: int = 1) -> bool:
	# Reject unknown jam types.
	if not jam_counts.has(jam_type):
		push_error("Unknown jam type: %s. Valid jam types: %s" % [jam_type, jam_counts.keys()])
		return false
	
	# Reject invalid amounts.
	if amount < 1:
		push_error("remove_jam amount must be at least 1. Got %d." % amount)
		return false
	
	# Prevent removing more jam than the player currently has.
	if jam_counts[jam_type] < amount:
		push_error("Not enough %s to remove. Have %d, tried to remove %d." % [jam_type, jam_counts[jam_type], amount])
		return false
	
	# Decrease the count for the given jam type.
	jam_counts[jam_type] -= amount
	
	# Notify anything listening that the inventory changed.
	inventory_changed.emit()
	return true
