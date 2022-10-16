extends Path2D

export var runSpeed = 1
var inPlayerArea = false
var canAttack = true
var object = null
var stateControl = state.PATROL
var positionOffset = Vector2(50,50)
var life = 3
var positionInSpawner
var spawnerRef
var atackRecoil = Vector2(0,0)
onready var sprite = $PathFollow2D/Sprite
onready var path = $PathFollow2D
var count = 0

enum state{
	PATROL,
	FOLLOW,
	BACK,
	ATTACK,
	RECOIL,
	PREPARE
}

func _process(delta):
	if atackRecoil != Vector2(0,0):
		sprite.global_position = sprite.global_position.move_toward(-atackRecoil, 4)
	
	else:
		match stateControl:
			state.PATROL:
				path.set_offset(path.get_offset() + runSpeed + delta)
			state.PREPARE:
				count += delta
				sprite.set_speed_scale(2)
				if count >= 0.5:
					stateControl = state.ATTACK
			state.ATTACK:
				if canAttack:
					Attack()
			state.FOLLOW:
				sprite.global_position = sprite.global_position.move_toward(object.position, 2)
			state.BACK:
				sprite.position = sprite.position.move_toward(Vector2(0,0), 2.5)
			state.RECOIL:
				sprite.position = sprite.position.move_toward(Vector2(0,0), 10)
		if sprite.position == Vector2(0,0):
			stateControl = state.PATROL
		if stateControl != state.PREPARE:
			sprite.set_speed_scale(1)
			count = 0
#	if (!loop and unit_offset == 1):
#		queue_free()

func Attack():
	if object != null:
		if object != null:
			sprite.play("Attack")
			sprite.global_position = sprite.global_position.move_toward(object.position, 15)
		
#		if $Sprite.global_position == object.global_position:
			
func TakeDamage(dir):
	#$PathFollow2D/Sprite/TakeDMG.play()

	life -= 1
	atackRecoil = dir
#	print("ai")
	if life <= 0:
		spawnerRef.enemyInPosition[positionInSpawner] = null
		queue_free()
	yield(get_tree().create_timer(0.2), "timeout")
	atackRecoil = Vector2(0,0)

func _on_AttackArea_body_entered(body):
	if "Player" in body.name:
#		print("atacando")
		stateControl = state.PREPARE

func _on_AttackArea_body_exited(body):
	if "Player" in body.name:
		stateControl = state.FOLLOW

func _on_PlayerFollowCheck_body_entered(body):
	if "Player" in body.name:
		stateControl = state.FOLLOW
		object = body

func _on_PlayerFollowCheck_body_exited(body):
	if "Player" in body.name:
		stateControl = state.BACK
		object = null

func _on_DamageArea_body_entered(body):
	if "Player" in body.name:
		if !body.isDashing and !body.falling:
			var dir = 0
			if sprite.global_position.x - object.global_position.x > 0:
				dir = -1
			else:
				dir = 1
			object.TakeDamage(dir)
		canAttack = false
		stateControl = state.RECOIL
#		print("voltou")
		yield(get_tree().create_timer(1), "timeout")
		canAttack = true

func _on_Sprite_animation_finished():
	sprite.play("Idle")
