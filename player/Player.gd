extends KinematicBody2D

const kunai_class = preload("res://player/Kunai.tscn")

onready var animated_sprite = $AnimatedSprite
onready var reset_timer = $ResetLevelTimer
onready var points_text = $Control/RichTextLabel

export var max_glide_speed = 150
export var max_speed = 600
export var jump_impulse = 900
export var gravity = 40

enum {
	IDLE,
	RUN,
	JUMP,
	GLIDE,
	FALL,
	DEAD
}

var velocity = Vector2()
var friction = 200
var acceleration = 350
var state = IDLE
var max_position_x = 0
var total_kills = 0

signal player_location

func _physics_process(delta):
	if state == DEAD:
		animate_player()
		return

	if Input.is_action_pressed("move_left"):
		velocity.x -= acceleration
	
	if Input.is_action_pressed("move_right"):
		velocity.x += acceleration
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y -= jump_impulse
		
	adjust_velocity()
	velocity = move_and_slide(velocity, Vector2.UP)

	if Input.is_action_just_pressed("fire"):
		fire_kunai(velocity.x)
		
	check_if_touched_enemy()
		
	animate_player()
	emit_signal("player_location", global_position.x, global_position.y)
	
	update_points()
	
	
func update_points():
	if position.x > max_position_x:
		max_position_x = position.x

	points_text.set_text("POINTS: " + str(floor(get_max_position() / 100) + 10 * get_kills()))


func check_if_touched_enemy():
	var slide_count = get_slide_count()
	for i in range(slide_count):
		var collision = get_slide_collision(i)
		var collider = collision.collider
		if collider.get_meta("type") == "enemy":
			if collider.is_dead():
				return
			state = DEAD
			
			reset_timer.start(1)      

func fire_kunai(x):
	var direction = 1
	if animated_sprite.flip_h:
		direction = -1

	var kunai = kunai_class.instance()
	kunai.position.y = position.y + 2
	kunai.position.x = position.x + 50 * direction
	kunai.init(direction)
	
	kunai.connect("killed_robot", self, "_on_robot_killed")
	
	get_tree().get_root().add_child(kunai)
		
func adjust_velocity():
	velocity.x = max(-max_speed, min(max_speed, velocity.x))
	if is_on_floor():
		velocity = velocity.move_toward(Vector2.ZERO, friction)
	
	if state == GLIDE:
		velocity.y += gravity / 3
		velocity.y = min(velocity.y, max_glide_speed)
	else:
		velocity.y += gravity
		velocity.y = min(velocity.y, max_speed)
	
func animate_player():
	# Make sure we face the correct direction.
	if velocity.x < -0.01 and not Input.is_action_pressed("move_right"):
		animated_sprite.flip_h = true
	elif velocity.x > 0.01 and not Input.is_action_pressed("move_left"):
		animated_sprite.flip_h = false

	# Animate the player
	match state:
		DEAD:
			animated_sprite.play("death")
			return
		FALL:
			animated_sprite.play("fall")
		GLIDE:
			animated_sprite.play("glide")
		IDLE:
			animated_sprite.play("idle")
		RUN:
			animated_sprite.play("run")
		JUMP:
			animated_sprite.play("jump")

	# Change the state.
	if velocity.x == 0 and velocity.y == 0 and not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		state = IDLE
	elif velocity.y != 0:
		if velocity.y > 0:
			if Input.is_action_pressed("jump"):
				state = GLIDE
			else:
				state = FALL
		else:
			state = JUMP
	elif velocity.x != 0:
		state = RUN

func _on_ResetLevelTimer_timeout():
	get_tree().change_scene("res://world/World.tscn")

func get_max_position():
	return max_position_x

func _on_robot_killed():
	total_kills += 1

func get_kills():
	return total_kills
