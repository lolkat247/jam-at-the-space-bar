extends Area2D

var _pivot: Node2D
var _target_angle: float = 0.0
var _sway_direction: float = 1.0

func _ready() -> void:
	BeatClock.beat.connect(_on_beat)
	_pivot = Node2D.new()
	_pivot.position = $TileMapLayer.position + Vector2(24, 12)
	add_child(_pivot)
	var tilemap = $TileMapLayer
	remove_child(tilemap)
	_pivot.add_child(tilemap)
	tilemap.position = Vector2(-24, -12)


func _on_beat() -> void:
	_sway_direction *= -1.0
	_target_angle = deg_to_rad(3.0) * _sway_direction


func _process(delta: float) -> void:
	_pivot.rotation = lerp(_pivot.rotation, _target_angle, 1.0 - exp(-8.0 * delta))
