extends Node

signal beat

@export var bpm = 0.0
@export var time_passed = 0.0

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# delta after previous beat
var delta_beat = 0.0

func _process(delta: float) -> void:
	if bpm == 0.0:
		bpm = 1.0
		
	var secs_per_beat: float = 60.0 / bpm
	
	delta_beat += delta
	time_passed += delta
	
	# assumes less than one beat has passed per frame
	if delta_beat > secs_per_beat:
		delta_beat -= secs_per_beat
		beat.emit()
		
	# check for catastrophy
	if delta_beat > secs_per_beat:
		print_debug("More than one beat has passed per frame uh oh")
