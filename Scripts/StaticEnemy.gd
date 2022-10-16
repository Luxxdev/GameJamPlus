extends AnimatedSprite

onready var tween = $Tween

func TakeDamage(dir):
	$TakeDMG.play()
	tween.interpolate_property(self, "scale", Vector2(0.8,0.8), Vector2(1,1), 0.1, tween.TRANS_BOUNCE, Tween.EASE_IN)
	tween.interpolate_property(self, "rotation_degrees", 10, 0, 0.1, tween.TRANS_BOUNCE, Tween.EASE_IN)
	tween.start()


func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		var dir
		if global_position.x - body.global_position.x > 0:
				dir = -1
		else:
			dir = 1
		body.TakeDamage(dir)
