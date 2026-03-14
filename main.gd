extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BeatClock.connect("beat", _on_beat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_beat() -> void:
	print_debug("Time passed: " + str(BeatClock.time_passed))
