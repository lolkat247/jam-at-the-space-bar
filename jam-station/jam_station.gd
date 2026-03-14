extends Area2D

signal jam_crafted

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_try_craft()


func _try_craft() -> void:
	if GameState.held_jam != "":
		return
	if GameState.craft_jam("basketbulb", "Basketball Jam"):
		jam_crafted.emit()
