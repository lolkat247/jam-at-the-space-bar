extends CharacterBody2D

var _queued_direction: Vector2i = Vector2i.ZERO
var _facing: Vector2i = Vector2i.UP
var _is_moving: bool = false
var _move_queue: Array[Vector2i] = [
	Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.UP,
	Vector2i.LEFT,
]

var _order_shown: bool = false
var _served: bool = false
var _arrow: Sprite2D
var _jam_sprite: Sprite2D

var _facing_textures := {
	Vector2i.DOWN: preload("res://sprites/toast_customer.png"),
	Vector2i.UP: preload("res://sprites/toast_customer_up.png"),
	Vector2i.LEFT: preload("res://sprites/toast_customer_right.png"),
	Vector2i.RIGHT: preload("res://sprites/toast_customer_left.png"),
}


func _ready() -> void:
	# if customer is registered load old position
	if GameState.current_order.get("pos"):
		position = GameState.current_order.get("pos")
		_move_queue = []
	
	if GameState.current_order.get("facing"):
		_set_facing(GameState.current_order.get("facing"))
	
	position = TileMovementManager._snap_to_grid(position)
	BeatClock.beat.connect(_on_beat)
	Inventory.inventory_changed.connect(_update_serve_indicator)

	# Green arrow indicator
	var arrow = Sprite2D.new()
	arrow.texture = preload("res://sprites/green_arrow.png")
	arrow.scale = Vector2(0.15, 0.15)
	arrow.position = Vector2(0, -80)
	arrow.visible = false
	add_child(arrow)
	_arrow = arrow

	# Jam sprite for OrderBubble swap (added under BubbleBg like the fruits)
	var bubble_bg = $AnimatedSprite2D/OrderBubble/BubbleBg
	var jam_spr = Sprite2D.new()
	jam_spr.texture = preload("res://sprites/basketball_jam.png")
	jam_spr.position = Vector2(0, -42.857)
	jam_spr.rotation = PI
	jam_spr.scale = Vector2(0.15, -0.15)
	jam_spr.visible = false
	bubble_bg.add_child(jam_spr)
	_jam_sprite = jam_spr

	# Area2D for detecting player overlap (serving)
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(32, 32)
	shape.shape = rect
	area.add_child(shape)
	area.body_entered.connect(_on_player_entered)
	add_child(area)

	if not GameState.current_order.is_empty():
		position = _compute_final_position()
		_move_queue.clear()
		_order_shown = true
		_set_facing(Vector2i.LEFT)
		$AnimatedSprite2D/OrderBubble.visible = true
		_update_serve_indicator()


func queue_direction(dir: Vector2i) -> void:
	_queued_direction = dir
	_set_facing(dir)


func _set_facing(dir: Vector2i) -> void:
	_facing = dir
	$AnimatedSprite2D.sprite_frames.set_frame("default", 0, _facing_textures[dir])


func _on_beat() -> void:
	# Bounce arrow on beat
	if _arrow.visible:
		var arrow_tween := create_tween()
		arrow_tween.tween_property(_arrow, "position:y", -100.0, 0.15)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		arrow_tween.tween_property(_arrow, "position:y", -80.0, 0.5)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			
	if _queued_direction == Vector2i.ZERO and _move_queue.size() > 0:
		var next_dir = _move_queue.pop_front()
		_queued_direction = next_dir
		_set_facing(next_dir)
	if _queued_direction == Vector2i.ZERO:
		if _served and _move_queue.size() == 0 and not _is_moving:
			queue_free()
			return
		if not _order_shown and not _served and _move_queue.size() == 0:
			_show_order()
		
		
		#ugly
		if not _is_moving:
			# TOAST BOUNCY BOUNCE BOUNCE ON THAT SHI
			var toast_sprite = $AnimatedSprite2D
			_is_moving = true
			var toast_tween := create_tween()
			var start_y = toast_sprite.position.y
			toast_tween.tween_property(toast_sprite, "position:y", start_y - 16.0, 0.08)\
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			toast_tween.tween_property(toast_sprite, "position:y", start_y, 0.08)\
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			
			toast_tween.finished.connect(_on_tween_finished)
		
		return
	if _is_moving:
		return
		
	
	

	var dir := _queued_direction
	_queued_direction = Vector2i.ZERO

	var target_pos: Vector2 = position + Vector2(dir * Global.TILE_SIZE)

	_is_moving = true
	var duration: float = (60.0 / maxf(BeatClock.bpm, 1.0)) * TileMovementManager.tween_fraction
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(_on_tween_finished)


func _on_tween_finished() -> void:
	_is_moving = false


func _compute_final_position() -> Vector2:
	var start := TileMovementManager._snap_to_grid(position)
	var offset := Vector2i.ZERO
	for dir in _move_queue:
		offset += dir
	return start + Vector2(offset * Global.TILE_SIZE)


func _show_order() -> void:
	_order_shown = true
	if GameState.current_order.is_empty():
		GameState.current_order = {
			"fruit": "Basketbulb",
			"jam": "Basketball Jam",
			"count": 3,
			"pos": position,
			"facing": _facing,
		}
	$AnimatedSprite2D/OrderBubble.visible = true
	_update_serve_indicator()


func _update_serve_indicator() -> void:
	if not _order_shown:
		return
	var has_jam := GameState.held_jam != ""
	# Swap bubble contents
	var bubble_bg = $AnimatedSprite2D/OrderBubble/BubbleBg
	bubble_bg.get_node("Fruit1").visible = not has_jam
	bubble_bg.get_node("Fruit2").visible = not has_jam
	bubble_bg.get_node("Fruit3").visible = not has_jam
	_jam_sprite.visible = has_jam
	# Arrow
	_arrow.visible = has_jam


func _on_player_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	if GameState.held_jam == "" or GameState.current_order.is_empty():
		return
	var jam_name = GameState.held_jam
	GameState.serve_jam()
	Inventory.remove_jam(jam_name)
	$AnimatedSprite2D/OrderBubble.visible = false
	_arrow.visible = false
	_spawn_confetti()
	_served = true
	_move_queue = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.DOWN, Vector2i.DOWN, Vector2i.DOWN, Vector2i.DOWN, Vector2i.DOWN, Vector2i.DOWN, Vector2i.DOWN, Vector2i.DOWN, Vector2i.DOWN, Vector2i.DOWN, Vector2i.DOWN]


func _spawn_confetti() -> void:
	var confetti = CPUParticles2D.new()
	confetti.emitting = true
	confetti.one_shot = true
	confetti.amount = 300
	confetti.lifetime = 3.0
	confetti.explosiveness = 0.95
	confetti.direction = Vector2(0, -1)
	confetti.spread = 180.0
	confetti.gravity = Vector2(0, 400)
	confetti.initial_velocity_min = 300.0
	confetti.initial_velocity_max = 700.0
	confetti.scale_amount_min = 4.0
	confetti.scale_amount_max = 8.0
	confetti.color = Color.WHITE
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color.RED, Color.YELLOW, Color.GREEN, Color.CYAN, Color.MAGENTA])
	gradient.offsets = PackedFloat32Array([0.0, 0.25, 0.5, 0.75, 1.0])
	confetti.color_ramp = gradient
	confetti.color_initial_ramp = gradient
	add_child(confetti)
	get_tree().create_timer(3.0).timeout.connect(confetti.queue_free)
