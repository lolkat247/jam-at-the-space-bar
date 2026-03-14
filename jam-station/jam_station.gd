extends Area2D

signal jam_crafted

var _base_scale: Vector2
var _arrow: Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_base_scale = $Sprite2D.scale
	BeatClock.beat.connect(_on_beat)
	Inventory.inventory_changed.connect(_update_arrow)

	var arrow = Sprite2D.new()
	arrow.texture = preload("res://sprites/green_arrow.png")
	arrow.scale = Vector2(0.15, 0.15)
	arrow.position = Vector2(0, -80)
	arrow.visible = false
	add_child(arrow)
	_arrow = arrow

	_update_arrow()


func _on_beat() -> void:
	var tween := create_tween()
	tween.tween_property($Sprite2D, "scale", _base_scale * 1.12, 0.15)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Sprite2D, "scale", _base_scale, 0.5)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

	if _arrow.visible:
		var arrow_tween := create_tween()
		arrow_tween.tween_property(_arrow, "position:y", -100.0, 0.15)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		arrow_tween.tween_property(_arrow, "position:y", -80.0, 0.5)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)


func _update_arrow() -> void:
	_arrow.visible = Inventory.has_fruit("Basketbulb", 3) and GameState.held_jam == ""


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_try_craft()


func _try_craft() -> void:
	if GameState.held_jam != "":
		return
	if GameState.craft_jam("Basketbulb", "Basketbulb Jam"):
		jam_crafted.emit()
		_update_arrow()
