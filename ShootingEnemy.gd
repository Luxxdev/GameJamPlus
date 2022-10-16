extends AnimatedSprite
class_name Enemy

#var angleConeOfVision = deg2rad(30.0)
#var maxViewDist = 800.0
#var angleBetweenRays = deg2rad(5.0)
var PlayerInArea = false
var target = null
onready var ray = $RayCast2D
export(PackedScene) var Bullet

func _process(delta):
	if PlayerInArea:
		look_at(target.global_position)
	if ray.is_colliding():
		if ray.get_collider() is Player:
			if $ShootDelay.is_stopped():
				Shoot()


func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		PlayerInArea = true
		target = body
 
func _on_Area2D_body_exited(body):
	if "Player" in body.name:
		PlayerInArea = false
		target = null

func Shoot():
	playing = true
	print("tiro")
	$ShootDelay.start()

#func GenerateRaycasts():
#	var rayCount = angleConeOfVision / angleBetweenRays
#	for i in rayCount:
#		var ray = RayCast2D.new()
#		var angle = angleBetweenRays * (i - rayCount / 2.0)
#		ray.cast_to = Vector2.UP.rotated(angle) * maxViewDist

func _on_ShootingEnemy_animation_finished():
	playing = false
	frame = 0
