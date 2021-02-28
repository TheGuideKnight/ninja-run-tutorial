extends Node2D

const robot_class = preload("res://enemy/Robot.tscn")

var last_x
var generated = []

# Called when the node enters the scene tree for the first time.
func _ready():
	generated.append(generate_robot(100, 0))

func generate_robot(x, y):
	var robot = robot_class.instance()
	
	robot.position.x = x
	robot.position.y = y
	
	add_child(robot)
	
	last_x = x
	return robot

func _on_Player_player_location(player_x, player_y):
	if last_x < player_x:
		generated.append(generate_robot(player_x + rand_range(300, 1500), player_y - 300))
