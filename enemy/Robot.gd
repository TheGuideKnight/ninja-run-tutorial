extends KinematicBody2D

onready var animated_sprite = $AnimatedSprite
onready var timer = $Timer

enum {
	IDLE,
	RUN,
	FALL
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
	timer.start(1)

func _physics_process(delta):
	if not ready:
		return
	velocity.y += gravity
	velocity = move_and_slide(velocity, Vector2.UP)
	animate_enemy()
	
func act():
	if state == FALL:
		return
	
	var random = rand_range(0, 1)
	if random < 0.3:
		velocity.x = 0
	elif random < 0.7:
		velocity.x -= speed
	else:
		velocity.x = speed

func animate_enemy():
	if velocity.x < -0.01:
		animated_sprite.flip_h = true
	elif velocity.x > 0.01:
		animated_sprite.flip_h = false
		
	match state:
		FALL:
			animated_sprite.play("jump")
		IDLE:
			animated_sprite.play("idle")
		RUN:
			animated_sprite.play("run")

	if velocity.x == 0 and velocity.y == 0:
		state = IDLE
	elif velocity.y != 0:
		if velocity.y > 0:
			state = FALL				
	elif velocity.x != 0:
		state = RUN


func _on_Timer_timeout():
	act()
	timer.start(rand_range(0.2, 3))
