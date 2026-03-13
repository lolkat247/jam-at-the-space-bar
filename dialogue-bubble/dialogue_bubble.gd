extends Control

# API usage:
# - Option 1: Set fruit_texture in the Inspector on this scene instance, then call show_order().
# - Option 2: Pass a texture in at runtime with show_order(texture).
# - Call hide_order() when the order bubble should disappear.
#
# Example using Inspector-assigned fruit:
# $DialogueBubble.show_order()
#
# Example using runtime-assigned fruit:
# $DialogueBubble.show_order(strawberry_texture)
#
# In that second case, `strawberry_texture` would come from whatever script is generating
# or storing the customer's order, e.g. a customer scene, order manager, or preloaded asset.

@onready var fruit_1: TextureRect = $"HBoxContainer/Fruit 1"
@onready var fruit_2: TextureRect = $"HBoxContainer/Fruit 2"
@onready var fruit_3: TextureRect = $"HBoxContainer/Fruit 3"

# Default / fallback fruit texture.
# If show_order() is called without an argument, this texture will be used instead.
@export var fruit_texture: Texture2D

func _ready():
	# Hide by default so it does not show until explicitly told to.
	hide()
	
	# Setup the fruit icons so they scale down nicely inside the bubble.
	for fruit in [fruit_1, fruit_2, fruit_3]:
		fruit.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		fruit.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		fruit.custom_minimum_size = Vector2(64, 64)
	
	# For testing:
	# show_order()
	# await get_tree().create_timer(2.0).timeout
	# hide_order()

func show_order(texture: Texture2D = fruit_texture):
	# If no texture was passed in and no default fruit_texture is assigned in the Inspector,
	# do nothing and warn.
	if texture == null:
		push_warning("No fruit texture was provided to show_order(), and fruit_texture is not assigned.")
		return
	
	# Show all 3 fruits and assign them the same texture.
	for fruit in [fruit_1, fruit_2, fruit_3]:
		fruit.visible = true
		fruit.texture = texture
	
	# Show the dialogue bubble itself.
	show()

func hide_order():
	# Hide the entire dialogue bubble, i.e. when the customer order has been fulfilled.
	hide()
