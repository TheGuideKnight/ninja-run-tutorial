extends RigidBody2D

onready var kunai_sprite = $Sprite

var speed = 600
var direction = 0

signal killed_robot

func _ready():
	gravity_scale = 0.1
	friction = 0
	if direction < 0:
		kunai_sprite.flip_h = true
	
func init(direction):
	self.direction = direction
	apply_impulse(Vector2(position.x - 20 * direction, 0), Vector2(speed * direction, 0))

	
func _on_DestroyTimer_timeout():
	queue_free()

func _on_Kunai_body_entered(body):
	if body.get_meta("type") == "enemy":
		body.kill()
		emit_signal("killed_robot")
		queue_free()
