extends AnimatedSprite
class_name Enemy

#var angleConeOfVision = deg2rad(30.0)
#var maxViewDist = 800.0
#var angleBetweenRays = deg2rad(5.0)
var PlayerInArea = false
var target = null
onready var ray = $RayCast2D
export(PackedScene) var Bullet
export(PackedScene) var Explode
var life = 3
var spawnerRef
var positionInSpawner

func _process(delta):
	if PlayerInArea:
		look_at(target.global_position)
	if ray.is_colliding():
		if ray.get_collider() is Player:
			if $ShootDelay.is_stopped():
				Shoot()
	if global_rotation_degrees >= 90 || global_rotation_degrees <= -90:
		flip_v = true
	else:
		flip_v = false


func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		PlayerInArea = true
		target = body
 
func _on_Area2D_body_exited(body):
	if "Player" in body.name:
		PlayerInArea = false
		target = null

func TakeDamage(dir):
	$TakeDMG.play()
	life -= 1
	if life <= 0:
		var explodeInstance = Explode.instance()
		explodeInstance.global_position = global_position
		get_parent().add_child(explodeInstance)
		spawnerRef.enemyInPosition[positionInSpawner] = null
		queue_free()

func Shoot():
	$Shoot.play()
	playing = true
	print("tiro")
	var bulletInstance = Bullet.instance()
	bulletInstance.rotation = get_parent().global_rotation
	bulletInstance.global_position = $Position2D.global_position
	bulletInstance.velocity = target.global_position - bulletInstance.position + Vector2(target.moveDir.x*50,target.moveDir.y*50)
	get_parent().get_parent().get_parent().add_child(bulletInstance)
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
