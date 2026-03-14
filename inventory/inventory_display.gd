# Inventory HUD display for fruits and jams
extends CanvasLayer

# Set these in the Inspector.
# These are the textures that will be used for the fruit and jam icons in the HUD.
@export var fruit_icon_texture: Texture2D
@export var jam_icon_texture: Texture2D

# References to the main HUD root and the two vertical icon lists.
# JamList is the left column and FruitList is the right column.
@onready var hud_root: Control = $HUDRoot
@onready var item_columns: HBoxContainer = $HUDRoot/ItemColumns
@onready var jam_list: VBoxContainer = $HUDRoot/ItemColumns/JamList
@onready var fruit_list: VBoxContainer = $HUDRoot/ItemColumns/FruitList

func _ready() -> void:
	# Position the HUD near the top-right corner of the screen.
	hud_root.anchor_left = 1.0
	hud_root.anchor_right = 1.0
	hud_root.anchor_top = 0.0
	hud_root.anchor_bottom = 0.0
	hud_root.offset_left = -140
	hud_root.offset_right = -16
	hud_root.offset_top = 16
	hud_root.offset_bottom = 400

	# Make ItemColumns fill HUDRoot so ALIGNMENT_END has room to work with.
	item_columns.anchor_left = 0.0
	item_columns.anchor_right = 1.0
	item_columns.anchor_top = 0.0
	item_columns.anchor_bottom = 1.0
	item_columns.offset_left = 0
	item_columns.offset_right = 0
	item_columns.offset_top = 0
	item_columns.offset_bottom = 0

	# Keep the two columns pushed to the right side of HUDRoot.
	item_columns.alignment = BoxContainer.ALIGNMENT_END

	# Rebuild the HUD whenever the inventory changes.
	Inventory.inventory_changed.connect(_rebuild_display)
	_rebuild_display()

#func _process(_delta: float) -> void:
	## Temporary test controls.
	## ui_right adds a fruit.
	#if Input.is_action_just_pressed("ui_right"):
		#Inventory.add_fruit("Basketbulb", 1)
#
	## ui_left removes a fruit.
	#if Input.is_action_just_pressed("ui_left"):
		#Inventory.remove_fruit("Basketbulb", 1)
#
	## ui_up adds a jam.
	#if Input.is_action_just_pressed("ui_up"):
		#Inventory.add_jam("Basketbulb Jam", 1)
#
	## ui_down removes a jam.
	#if Input.is_action_just_pressed("ui_down"):
		#Inventory.remove_jam("Basketbulb Jam", 1)

func _rebuild_display() -> void:
	# Clear both icon columns before rebuilding them from inventory state.
	_clear_list(jam_list)
	_clear_list(fruit_list)

	# Get the current jam and fruit counts from inventory.
	var jam_count: int = Inventory.get_jam_count("Basketbulb Jam")
	var fruit_count: int = Inventory.get_fruit_count("Basketbulb")

	# Only show the jam column if there is at least one jam.
	jam_list.visible = jam_count > 0

	# Only show the fruit column if there is at least one fruit.
	fruit_list.visible = fruit_count > 0

	# Add one jam icon for each jam currently in inventory.
	for i in range(jam_count):
		jam_list.add_child(_make_icon(jam_icon_texture))

	# Add one fruit icon for each fruit currently in inventory.
	for i in range(fruit_count):
		fruit_list.add_child(_make_icon(fruit_icon_texture))

	# Force the HBoxContainer to recalculate layout now.
	item_columns.queue_sort()

func _clear_list(list_node: VBoxContainer) -> void:
	# Remove all existing icons from the given vertical list immediately.
	for child in list_node.get_children():
		child.free()

func _make_icon(texture: Texture2D) -> TextureRect:
	# Create a new icon node for the HUD using the given texture.
	var icon := TextureRect.new()

	# Assign the texture to the icon.
	icon.texture = texture

	# Make the icon scale nicely inside its box.
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(64, 64)

	return icon
