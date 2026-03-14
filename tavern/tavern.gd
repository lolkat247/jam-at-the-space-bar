extends Node2D


func _ready() -> void:
	MusicManager.play_track("bar")


func _process(delta: float) -> void:
	$GalaxyWindow.position += Vector2(-3.0, 1.5) * delta
