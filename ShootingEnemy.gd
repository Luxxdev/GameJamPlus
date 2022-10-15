extends Sprite
class_name Enemy

var angleConeOfVision = deg2rad(30.0)
var maxViewDist = 800.0
var angleBetweenRays = deg2rad(5.0)
var PlayerInArea = false
var target = null


func _process(delta):
	if PlayerInArea:
		look_at(target.global_position)
	if $RayCast2D.is_colliding():
		if $RayCast2D.get_collider() is Player:
			print('aaaa')
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
	print("tiro")
	$ShootDelay.start()

func GenerateRaycasts():
	var rayCount = angleConeOfVision / angleBetweenRays
	
	for i in rayCount:
		var ray = RayCast2D.new()
		var angle = angleBetweenRays * (i - rayCount / 2.0)
		ray.cast_to = Vector2.UP.rotated(angle) * maxViewDist
