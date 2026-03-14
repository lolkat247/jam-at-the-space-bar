extends Node

# not global because likely to change
var max_fruits = 5

func get_rand_tile_pos(left_corner: Vector2, right_corner: Vector2) -> Vector2:
	var num_tiles_x: int = (right_corner.x - left_corner.x) / Global.TILE_SIZE
	var num_tiles_y: int = (right_corner.y - left_corner.y) / Global.TILE_SIZE
	
	# padding of 1 around foreground to avoid clipping
	var rand_x = randi() % (num_tiles_x - 1) + 1
	var rand_y = randi() % (num_tiles_y - 1) + 1
	
	return Vector2(rand_x*Global.TILE_SIZE, rand_y*Global.TILE_SIZE)

# manual deep search because objects are compared by reference
func does_arr_contain_vec(arr: Array, vec: Vector2):
	for cur in arr:
		if cur.x == vec.x and cur.y == vec.y:
			return true
	
	return false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var basket_bulb = load("res://fruits/basket_bulb.tscn")
	
	var fruits = [basket_bulb]
	
	var chosen_cords = []
	
	for i in range(max_fruits):
		var rand_fruit = randi() % len(fruits)
		var fruit = fruits[rand_fruit].instantiate()
		
		# edit to size of foreground l8r because it might 
		# be different from window size
		var rand_tile = get_rand_tile_pos(Vector2.ZERO, DisplayServer.window_get_size())
		var uhoh_count = 0
		while does_arr_contain_vec(chosen_cords, rand_tile) and uhoh_count < 1000:
			rand_tile = get_rand_tile_pos(Vector2.ZERO, DisplayServer.window_get_size())
			uhoh_count += 1
			
		# will probably only trigger if u fill the map with fruits
		if uhoh_count >= 1000:
			print_debug("uh oh")
		
		chosen_cords.append(rand_tile)
		
		fruit.position = rand_tile
		
		add_child(fruit)
