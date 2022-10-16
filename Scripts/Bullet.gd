extends Area2D

var target = null
var speed = 75
var velocity

func _physics_process(delta):
	target = get_parent()
	if target.get_ref():
		velocity = ((target.get_ref().get_global_position() - 
		position).normalized() * speed)
		position += velocity * delta
		rotation = velocity


func _on_Bullet_body_entered(body):
	queue_free()
