extends Control

@export var fruit_texture: Texture2D

@onready var fruit_1: TextureRect = $"HBoxContainer/Fruit 1"
@onready var fruit_2: TextureRect = $"HBoxContainer/Fruit 2"
@onready var fruit_3: TextureRect = $"HBoxContainer/Fruit 3"

func _ready():
	hide()

	for fruit in [fruit_1, fruit_2, fruit_3]:
		fruit.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		fruit.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		fruit.custom_minimum_size = Vector2(24, 24)

func show_order():
	for fruit in [fruit_1, fruit_2, fruit_3]:
		fruit.texture = fruit_texture
		fruit.visible = true

	show()

func hide_order():
	hide()
