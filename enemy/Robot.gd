extends KinematicBody2D

onready var animated_sprite = $AnimatedSprite
onready var action_timer = $ActionTimer
onready var death_timer = $DeathTimer
onready var collision_shape = $CollisionShape2D

enum {
	IDLE,
	RUN,
	FALL,
	DEAD
}

const gravity = 100

var velocity = Vector2()
var speed = 200
var state = IDLE
var ready

# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("type", "enemy")
	ready = true
	action_timer.start(1)

func _physics_process(delta):
	if not ready:
		return
		
	if state == DEAD:
		velocity.x = 0
	velocity.y += gravity
	velocity = move_and_slide(velocity, Vector2.UP)
	animate_enemy()
	
func act():
	if state == FALL or state == DEAD:
		return
	
	var random = rand_range(0, 1)
	if random < 0.3:
		velocity.x = 0
	elif random < 0.7:
		velocity.x -= speed
	else:
		velocity.x = speed

func animate_enemy():
	match state:
		DEAD:
			animated_sprite.play("dead")
			return
		FALL:
			animated_sprite.play("jump")
		IDLE:
			animated_sprite.play("idle")
		RUN:
			animated_sprite.play("run")

	if velocity.x < -0.01:
		animated_sprite.flip_h = true
	elif velocity.x > 0.01:
		animated_sprite.flip_h = false
		
	if velocity.x == 0 and velocity.y == 0:
		state = IDLE
	elif velocity.y != 0:
		if velocity.y > 0:
			state = FALL				
	elif velocity.x != 0:
		state = RUN


func _on_Timer_timeout():
	act()
	action_timer.start(rand_range(0.2, 3))

func is_dead():
	return state == DEAD

func kill():
	if state != DEAD:
		# Make the robot cannot kill or hinder the player
		set_collision_layer(2)
		state = DEAD
		death_timer.start(10)
	
func _on_DeathTimer_timeout():
	queue_free()

# Sets the robot size, accepted values are from 10 to 100
func set_size(value):
	assert(value >= 5 && value <= 20)
	var current_size_collision_shape = collision_shape.scale.x
	var current_size_sprite = animated_sprite.scale.x
	
	collision_shape.scale.x = current_size_collision_shape * (value / 10.0)
	collision_shape.scale.y = current_size_collision_shape * (value / 10.0)
	
	animated_sprite.scale.x = current_size_sprite * (value / 10.0)
	animated_sprite.scale.y = current_size_sprite * (value / 10.0)

