extends Node2D

const robot_class = preload("res://enemy/Robot.tscn")

onready var request = $HTTPRequest

var last_x
var needs_resizing = []

# Called when the node enters the scene tree for the first time.
func _ready():
	needs_resizing.append(generate_robot(100, 0))
	request.connect("request_completed", self, "_on_request_completed")
	do_REST_resize_call()

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(str("Web server replied: ", json.result, ". Scaling robot..."))
	# Resize the first not resized robot:
	if len(needs_resizing) > 0:
		needs_resizing[0].set_size(json.result[0])
		needs_resizing.remove(0)

func generate_robot(x, y):
	var robot = robot_class.instance()

	robot.position.x = x
	robot.position.y = y	
	
	add_child(robot)
	
	last_x = x
	
	return robot

func _on_Player_player_location(player_x, player_y):
	if last_x < player_x:
		needs_resizing.append(generate_robot(player_x + rand_range(300, 1500), player_y - 300))
		do_REST_resize_call()

func do_REST_resize_call():
	# Deal with the robot resizing.
	request.request("http://www.randomnumberapi.com/api/v1.0/random?min=10&max=100&count=1")

