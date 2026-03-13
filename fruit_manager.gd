extends Node

var fruits = [$BasketBulb]
# not global because likely to change
var max_fruits = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var chosen_coords = []
	for i in range(max_fruits):
		var rand_fruit = randi() % len(fruits)
		var fruit = fruits[rand_fruit].new()
		
		var rand_tile = Global.get_rand_tile_pos()
		
		fruit.position = rand_tile
		
		add_child(fruit)
