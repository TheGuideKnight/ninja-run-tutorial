extends Node2D

onready var tile_map = $TileMap

const vertical_cells = 14
const cell_width = 32
const cell_height = 32

var current_x = 0
var current_y = 14

var cross_id = -1
var horizontal_id = -1
var horizontal_left_id = -1
var horizontal_right_id = -1
var horizontal_both_id = -1
var vertical_id = -1
var vertical_top_id = -1
var vertical_bottom_id = -1
var vertical_both_id = -1
var curve_left_top_id = -1
var curve_bottom_right_id = -1
var curve_left_bottom_id = -1
var curve_top_right_id = -1
var t_bottom_id = -1
var t_right_id = -1
var t_top_id = -1
var t_left_id = -1

var previous_batch
var current_batch
var next_batch

var batch_size = 4
var current_batch_start_x
var current_batch_start_y
var current_batch_end_y

# Called when the node enters the scene tree for the first time.
func _ready():
	seed(1)
	cross_id = tile_map.tile_set.find_tile_by_name("cross")
	horizontal_id = tile_map.tile_set.find_tile_by_name("horizontal")
	horizontal_left_id = tile_map.tile_set.find_tile_by_name("horizontal_left")
	horizontal_right_id = tile_map.tile_set.find_tile_by_name("horizontal_right")
	horizontal_both_id = tile_map.tile_set.find_tile_by_name("horizontal_both")
	vertical_id = tile_map.tile_set.find_tile_by_name("vertical")
	vertical_top_id = tile_map.tile_set.find_tile_by_name("vertical_top")
	vertical_bottom_id = tile_map.tile_set.find_tile_by_name("vertical_bottom")
	vertical_both_id = tile_map.tile_set.find_tile_by_name("vertical_both")
	curve_left_top_id = tile_map.tile_set.find_tile_by_name("curve_left_top")
	curve_bottom_right_id = tile_map.tile_set.find_tile_by_name("curve_bottom_right")
	curve_left_bottom_id = tile_map.tile_set.find_tile_by_name("curve_left_bottom")
	curve_top_right_id = tile_map.tile_set.find_tile_by_name("curve_top_right")
	t_bottom_id = tile_map.tile_set.find_tile_by_name("t_bottom")
	t_right_id = tile_map.tile_set.find_tile_by_name("t_right")
	t_top_id = tile_map.tile_set.find_tile_by_name("t_top")
	t_left_id = tile_map.tile_set.find_tile_by_name("t_left")
	
	current_batch_start_x = -2
	batch_size = 5
	
	previous_batch = generate_batch(current_batch_start_x - batch_size, current_batch_start_x, 10)
	current_batch = generate_batch(current_batch_start_x, current_batch_start_x + batch_size, get_y(previous_batch))
	next_batch = generate_batch(current_batch_start_x + batch_size, current_batch_start_x + 2 * batch_size, get_y(current_batch))
	
	update_start_end_y(current_batch)


func get_y(batch):
	return batch[batch.size() - 1]["y"]
	
func update_start_end_y(batch):
	current_batch_start_y = batch[0]["y"]
	current_batch_start_y = batch[batch.size() - 1]["y"]

func clear_batch(batch):
	for i in range(batch.size()):
		var value = batch[i]
		tile_map.set_cell(value["x"], value["y"], -1)

func move_up():
	current_y -= 1
	
func move_right():
	current_x += 1

func move_down():
	current_y += 1

func generate_batch(start_x, end_x, start_y):
	var c_y = start_y
	var batch = []
	
	for c_x in range(start_x, end_x):
		var random = rand_range(0, 1)
		var sub_batch
		if random < 0.15:
			# Add a wall. Determine the height of [1-3]
			c_y = generate_ascending_path(c_x, c_y, batch)
		elif random < 0.45:
			c_y = generate_descending_path(c_x, c_y, batch)
		else:
			tile_map.set_cell(c_x, c_y, horizontal_both_id)
			batch.append({"x": c_x, "y": c_y})
				
	return batch


func generate_ascending_path(c_x, c_y, batch):
	tile_map.set_cell(c_x, c_y, curve_left_top_id)
	batch.append({"x": c_x, "y": c_y})
	c_y -= 1
	var random = rand_range(1, 2)
	for j in range(1, random):
		tile_map.set_cell(c_x, c_y, vertical_both_id)
		batch.append({"x": c_x, "y": c_y})
		c_y -= 1
	tile_map.set_cell(c_x, c_y, curve_bottom_right_id)
	batch.append({"x": c_x, "y": c_y})
	return c_y
	
func generate_descending_path(c_x, c_y, batch):
	tile_map.set_cell(c_x, c_y, curve_left_bottom_id)
	batch.append({"x": c_x, "y": c_y})
	c_y += 1
	var random = rand_range(1, 2)
	for j in range(1, random):
		tile_map.set_cell(c_x, c_y, vertical_both_id)
		batch.append({"x": c_x, "y": c_y})
		c_y += 1
	tile_map.set_cell(c_x, c_y, curve_top_right_id)
	batch.append({"x": c_x, "y": c_y})
	return c_y
	
#func generate_ascending_path():
#	tile_map.set_cell(current_x, current_y, curve_left_top_id)
#	move_up()
#	var random = rand_range(1, 3)
#	for j in range(1, random):
#		tile_map.set_cell(current_x, current_y, vertical_both_id)
#		move_up()
#	tile_map.set_cell(current_x, current_y, curve_bottom_right_id)
#	move_right()

#func generate_descending_path():
#	tile_map.set_cell(current_x, current_y, curve_left_bottom_id)
#	move_down()
#	var random = rand_range(1, 7)
#	for j in range(1, random):
#		tile_map.set_cell(current_x, current_y, vertical_both_id)
#		move_down()
#	tile_map.set_cell(current_x, current_y, curve_top_right_id)
#	move_right()
			
func _on_Timer_timeout():
	tile_map.set_cell(2,2,-1)


func _on_Player_player_location(position_x):
	var current_cell_position = floor(position_x / cell_width)
#	if current_cell_position < current_batch_start_x:
#		current_batch_start_x -= batch_size
#		clear_batch(next_batch)
#		next_batch = current_batch
#		current_batch = previous_batch
#		previous_batch = generate_batch(current_batch_start_x - batch_size, current_batch_start_x, get_y(current_batch))
#		print("generated previous batch")
	if current_cell_position > current_batch_start_x + batch_size:
		current_batch_start_x += batch_size
		clear_batch(previous_batch)
		previous_batch = current_batch
		current_batch = next_batch		
		next_batch = generate_batch(current_batch_start_x + batch_size, current_batch_start_x + 2 * batch_size, get_y(current_batch))
		print("generated next batch")
#	print(str('current_cell_position: ', current_cell_position) , "current_batch_start_x: ", current_batch_start_x)
