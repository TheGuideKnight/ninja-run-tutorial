extends Node2D

onready var tile_map = $TileMap

const vertical_cells = 14
const cell_width = 32
const cell_height = 32

var current_x = 0
var current_y = 14

var previous_batch
var current_batch
var next_batch
var stop_batch # used to block the player from returning.

var batch_size = 4
var current_batch_start_x
var current_batch_start_y
var current_batch_end_y

# Called when the node enters the scene tree for the first time.
func _ready():

	seed(1)

	current_batch_start_x = -2
	batch_size = 50
	
	previous_batch = generate_batch(current_batch_start_x - batch_size, current_batch_start_x, 10)
	current_batch = generate_batch(current_batch_start_x, current_batch_start_x + batch_size, get_y(previous_batch))
	next_batch = generate_batch(current_batch_start_x + batch_size, current_batch_start_x + 2 * batch_size, get_y(current_batch))
	stop_batch = generate_stop_batch(current_batch_start_x - batch_size - 1, 10)
	update_start_end_y(current_batch)

func get_tile(name) -> int:
	return tile_map.tile_set.find_tile_by_name(name)

func get_y(batch):
	return batch[batch.size() - 1]["y"]
	
func update_start_end_y(batch):
	current_batch_start_y = batch[0]["y"]
	current_batch_start_y = batch[batch.size() - 1]["y"]

func clear_batch(batch):
	for i in range(batch.size()):
		var value = batch[i]
		tile_map.set_cell(value["x"], value["y"], -1)

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
			batch.append(add_pipe(c_x, c_y, get_tile("horizontal_both")))
				
	return batch
	
func add_pipe(x, y, pipe_id):
	tile_map.set_cell(x, y, pipe_id)
	return {"x": x, "y": y}

# This generates the pipe on the left of the map that blocks the player movement.
func generate_stop_batch(c_x, c_y):
	var horizontal_size = 5
	var vertical_size = 10
	var batch = []
	batch.append(add_pipe(c_x, c_y, get_tile("curve_top_right")))
	c_y -= 1

	batch.append(add_pipe(c_x, c_y, get_tile("vertical_bottom")))
	c_y -= 1
	
	for i in range(vertical_size):
		batch.append(add_pipe(c_x, c_y, get_tile("vertical")))
		c_y -= 1
	
	batch.append(add_pipe(c_x, c_y, get_tile("vertical_top")))
	c_y -= 1
	
	batch.append(add_pipe(c_x, c_y, get_tile("curve_bottom_right")))
	c_x += 1

	batch.append(add_pipe(c_x, c_y, get_tile("horizontal_left")))
	c_x += 1

	for i in range(horizontal_size):
		batch.append(add_pipe(c_x, c_y, get_tile("horizontal_both")))
		c_x += 1
	return batch
	
# Generates an ascending path of 1 tile in the x direction.
func generate_ascending_path(c_x, c_y, batch):
	batch.append(add_pipe(c_x, c_y, get_tile("curve_left_top")))
	c_y -= 1
	var random = rand_range(1, 2)
	for j in range(1, random):
		batch.append(add_pipe(c_x, c_y, get_tile("vertical_both")))
		c_y -= 1
	batch.append(add_pipe(c_x, c_y, get_tile("curve_bottom_right")))
	return c_y

# Generates a descending path of 1 tile in the x direction.
func generate_descending_path(c_x, c_y, batch):
	batch.append(add_pipe(c_x, c_y, get_tile("curve_left_bottom")))
	c_y += 1
	var random = rand_range(1, 2)
	for j in range(1, random):
		batch.append(add_pipe(c_x, c_y, get_tile("vertical_both")))
		c_y += 1
	batch.append(add_pipe(c_x, c_y, get_tile("curve_top_right")))
	return c_y

# Manage the tile map objects
func _on_Player_player_location(position_x, position_y):
	var current_cell_position = floor(position_x / cell_width)
	if current_cell_position > current_batch_start_x + batch_size:
		current_batch_start_x += batch_size
		clear_batch(previous_batch)
		clear_batch(stop_batch)
		stop_batch = generate_stop_batch(current_batch_start_x - batch_size - 1, current_batch[0]["y"])
		previous_batch = current_batch
		current_batch = next_batch		
		next_batch = generate_batch(current_batch_start_x + batch_size, current_batch_start_x + 2 * batch_size, get_y(current_batch))

