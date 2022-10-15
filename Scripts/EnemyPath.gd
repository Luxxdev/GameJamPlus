extends PathFollow2D

export var runSpeed = 1

func _process(delta):
	set_offset(get_offset() + runSpeed + delta)
	
#	if (!loop and unit_offset == 1):
#		queue_free()


func _on_PlayerAreaCheck_body_entered(body):
		if "Player" in body.name:
			pass

func _on_PlayerAreaCheck_body_exited(body):
	$Sprite.position = Vector2(0,0)
