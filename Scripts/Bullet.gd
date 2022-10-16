extends KinematicBody2D 

var target = null
var speed = 150
var velocity = Vector2(0,0)

func _physics_process(delta):
	position += velocity * delta
	var collisionInfo = move_and_collide(velocity.normalized() * delta * speed)

func _on_Bullet_body_entered(body):
	if "Player" in body.name:
		if (global_position.x < body.global_position.x):
			body.TakeDamage(1)
		else:
			body.TakeDamage(-1)
	queue_free()
