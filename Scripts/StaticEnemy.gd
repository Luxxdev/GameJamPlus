extends AnimatedSprite

onready var tween = $Tween

func TakeDamage(dir):
	$TakeDMG.play()
	tween.interpolate_property(self, "scale", Vector2(0.8,0.8), Vector2(1,1), 0.1, tween.TRANS_BOUNCE, Tween.EASE_IN)
	tween.interpolate_property(self, "rotation_degrees", 10, 0, 0.1, tween.TRANS_BOUNCE, Tween.EASE_IN)
	tween.start()
