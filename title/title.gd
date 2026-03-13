extends Control


func _ready() -> void:
	MusicManager.play_track("title")
	$PlayButton.pressed.connect(_on_play_pressed)


func _on_play_pressed() -> void:
	MusicManager.transition_at_loop_end("res://tavern/tavern.tscn", "bar")
