extends KinematicBody2D

const kunai_class = preload("res://player/Kunai.tscn")

onready var animated_sprite = $AnimatedSprite
onready var reset_timer = $ResetLevelTimer
onready var points_text = $Control/RichTextLabel

export var immortal = false
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
	DEAD,
	THROW_KUNAI
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

	if Input.is_action_pressed("move_left") and not state == THROW_KUNAI:
		velocity.x -= acceleration
	
	if Input.is_action_pressed("move_right") and not state == THROW_KUNAI:
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
			if collider.is_dead() or immortal:
				return
			state = DEAD
			
			reset_timer.start(1)      

func fire_kunai(x):
	state = THROW_KUNAI
	var direction = 1
	if animated_sprite.flip_h:
		direction = -1

	var kunai = kunai_class.instance()
	kunai.position.y = position.y + 2
	kunai.position.x = position.x + 5 * direction
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
	if Input.is_action_pressed("move_left"):
		animated_sprite.flip_h = true
	elif Input.is_action_pressed("move_right"):
		animated_sprite.flip_h = false

	# Animate the player
	match state:
		DEAD:
			animated_sprite.play("death")
			return
		FALL:
			animated_sprite.play("fall")
			if check_glide() or check_idle() or check_throw() or check_run():
				return
		GLIDE:
			animated_sprite.play("glide")
			if check_idle() or check_fall() or check_throw() or check_run():
				return
		IDLE:
			animated_sprite.play("idle")
			if check_run() or check_jump() or check_throw():
				return
		RUN:
			animated_sprite.play("run")
			if check_idle() or check_jump() or check_throw():
				return
		JUMP:
			animated_sprite.play("jump")
			if check_idle() or check_fall() or check_glide() or check_throw() or check_run():
				return
		THROW_KUNAI:
			animated_sprite.play("throw_kunai")
			
			var current_frame = animated_sprite.get_frame()
			var total_frames = animated_sprite.get_sprite_frames().get_frame_count("throw_kunai")
			
			if current_frame >= total_frames - 1 and (check_fall() or check_glide() or check_idle() or check_run()):
				return
			
			
func check_idle():
	if is_on_floor() and (not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left")):
		print("-> Idle")
		state = IDLE
		return true
	return false
	
func check_glide():
	if velocity.y > 0 and Input.is_action_pressed("jump"):
		print("-> Glide")
		state = GLIDE
		return true
	return false
		
func check_run():
	if is_on_floor() and (Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left")):
		print(str("-> Run, ", is_on_floor()))
		state = RUN
		return true
	return false

func check_jump():
	if velocity.y != 0 and Input.is_action_just_pressed("jump"):
		print("-> Jump")
		state = JUMP
		return true
	return false

func check_fall():
	if velocity.y > 0 and not Input.is_action_pressed("jump"):
		print("-> Fall")
		state = FALL
		return true
	return false

func check_throw():
	if Input.is_action_just_pressed("fire"):
		print("-> Throw")
		state = THROW_KUNAI
		return true
	return false

func _on_ResetLevelTimer_timeout():
	get_tree().change_scene("res://world/World.tscn")

func get_max_position():
	return max_position_x

func _on_robot_killed():
	total_kills += 1

func get_kills():
	return total_kills
