extends AnimatedSprite

onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func TakeDamage(dir):
	tween.interpolate_property(self, "scale", Vector2(0.7,0.7), Vector2(1,1), 0.2, tween.TRANS_ELASTIC, Tween.EASE_IN)
	tween.interpolate_property(self, "rotation_degrees", 10, 0, 0.2, tween.TRANS_ELASTIC, Tween.EASE_IN)
	tween.start()
