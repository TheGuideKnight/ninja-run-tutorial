extends KinematicBody2D

onready var animated_sprite = $AnimatedSprite

export var max_glide_speed = 150
export var max_speed = 400
export var jump_impulse = 900
export var gravity = 40

enum {
	IDLE,
	RUN,
	JUMP,
	GLIDE,
	FALL
}

var velocity = Vector2()
var friction = 200
var acceleration = 350
var state = IDLE

signal player_location

func _physics_process(delta):
	if Input.is_action_pressed("move_left"):
		velocity.x -= acceleration
	
	if Input.is_action_pressed("move_right"):
		velocity.x += acceleration
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y -= jump_impulse
		
	adjust_velocity()
	velocity = move_and_slide(velocity, Vector2.UP)
	animate_player()
	emit_signal("player_location", global_position.x)
	
	
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
	if velocity.x < 0.01 and not Input.is_action_pressed("move_right"):
		animated_sprite.flip_h = true
	elif velocity.x > 0.01 and not Input.is_action_pressed("move_left"):
		animated_sprite.flip_h = false
		
	match state:
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
	
