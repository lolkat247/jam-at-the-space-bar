extends CharacterBody2D

var _queued_direction: Vector2i = Vector2i.ZERO
var _is_moving: bool = false
@onready var ray_cast = get_node_or_null("RayCast2D") as RayCast2D

var colliding = null
var col_point = null
var local_col_point = null


var _facing_textures := {
	Vector2i.DOWN: preload("res://sprites/astronaut_chef.png"),
	Vector2i.UP: preload("res://sprites/astronaut_chef_up.png"),
	Vector2i.LEFT: preload("res://sprites/astronaut_chef_left.png"),
	Vector2i.RIGHT: preload("res://sprites/astronaut_chef_right.png"),
}


func _ready() -> void:
	position = TileMovementManager._snap_to_grid(position)
	BeatClock.beat.connect(_on_beat)


func _process(_delta: float) -> void:
	# Buffer the most recent directional input (last-wins)
	if Input.is_action_pressed("arrow_right"):
		_queued_direction = Vector2i.RIGHT
		_set_facing(Vector2i.RIGHT)
	elif Input.is_action_pressed("arrow_left"):
		_queued_direction = Vector2i.LEFT
		_set_facing(Vector2i.LEFT)
	elif Input.is_action_pressed("arrow_down"):
		_queued_direction = Vector2i.DOWN
		_set_facing(Vector2i.DOWN)
	elif Input.is_action_pressed("arrow_up"):
		_queued_direction = Vector2i.UP
		_set_facing(Vector2i.UP)


#func _physics_process(delta: float) -> void:
	#if ray_cast.is_colliding():
		#colliding = ray_cast.get_collider()
		#col_point = ray_cast.get_collision_point()
		#local_col_point = to_local(col_point)



func _set_facing(dir: Vector2i) -> void:
	$AnimatedSprite2D.sprite_frames.set_frame("default", 0, _facing_textures[dir])


func _on_beat() -> void:
	var tile_size = Global.TILE_SIZE
	if get_parent() is Node and get_parent().name == "TestOverworld":
		tile_size = Global.OVERWORLD_TILE_SIZE
	if _queued_direction == Vector2i.ZERO:
		return
	if _is_moving:
		return

	var dir := _queued_direction
	_queued_direction = Vector2i.ZERO


	var target_pos: Vector2 = position + Vector2(dir * tile_size)
	ray_cast.target_position = Vector2(dir * (tile_size))
	
	if ray_cast.is_colliding():
		print("colliding")
		colliding = ray_cast.get_collider()
		col_point = ray_cast.get_collision_point()
		local_col_point = to_local(col_point)
	
	_is_moving = true
	var duration: float = (60.0 / maxf(BeatClock.bpm, 1.0)) * TileMovementManager.tween_fraction
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(_on_tween_finished)


func _on_tween_finished() -> void:
	_is_moving = false
