extends Area2D

signal jam_crafted

var _base_scale: Vector2

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_base_scale = $Sprite2D.scale
	BeatClock.beat.connect(_on_beat)


func _on_beat() -> void:
	var tween := create_tween()
	tween.tween_property($Sprite2D, "scale", _base_scale * 1.12, 0.15)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Sprite2D, "scale", _base_scale, 0.5)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_try_craft()


func _try_craft() -> void:
	if GameState.held_jam != "":
		return
	if GameState.craft_jam("Basketbulb", "Basketbulb Jam"):
		jam_crafted.emit()
