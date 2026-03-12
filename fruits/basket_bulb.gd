extends Area2D

signal fruit_collected(fruit_type)

@export var fruit_type: String = "BasketBulb"

func _on_body_entered(body):
	emit_signal("fruit_collected", fruit_type)
	# Remove the element from memory
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass	
