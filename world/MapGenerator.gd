extends Node2D


onready var tile_map = $TileMap

const vertical_cells = 14

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
	
	generate_batch()

func move_up():
	current_y -= 1
	
func move_right():
	current_x += 1

func move_down():
	current_y += 1

func generate_batch():
	for i in range(0, 600):
		var random = rand_range(0, 1)
		if random < 0.15:
			# Add a wall. Determine the height of [1-3]
			generate_ascending_path()
		elif random < 0.85:
			tile_map.set_cell(current_x, current_y, horizontal_both_id)
			move_right()
		else:
			generate_descending_path()


func generate_ascending_path():
	tile_map.set_cell(current_x, current_y, curve_left_top_id)
	move_up()
	var random = rand_range(1, 3)
	for j in range(1, random):
		tile_map.set_cell(current_x, current_y, vertical_both_id)
		move_up()
	tile_map.set_cell(current_x, current_y, curve_bottom_right_id)
	move_right()

func generate_descending_path():
	tile_map.set_cell(current_x, current_y, curve_left_bottom_id)
	move_down()
	var random = rand_range(1, 7)
	for j in range(1, random):
		tile_map.set_cell(current_x, current_y, vertical_both_id)
		move_down()
	tile_map.set_cell(current_x, current_y, curve_top_right_id)
	move_right()
			
func _on_Timer_timeout():
	tile_map.set_cell(2,2,-1)
