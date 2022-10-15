extends PathFollow2D

export var runSpeed = 1
var inPlayerArea = false
var canAttack = true
var object = null
var stateControl = state.PATROL
var positionOffset = Vector2(50,50)

enum state{
	PATROL,
	FOLLOW,
	BACK,
	ATTACK,
	RECOIL
}

func _process(delta):
	match stateControl:
		state.PATROL:
			set_offset(get_offset() + runSpeed + delta)
		state.ATTACK:
			if canAttack:
				Attack()
		state.FOLLOW:
			$Sprite.global_position = $Sprite.global_position.move_toward(object.position, 2)
		state.BACK:
			$Sprite.position = $Sprite.position.move_toward(Vector2(0,0), 2.5)
		state.RECOIL:
			$Sprite.position = $Sprite.position.move_toward(Vector2(0,0), 10)
	if $Sprite.position == Vector2(0,0):
		stateControl = state.PATROL
#	if (!loop and unit_offset == 1):
#		queue_free()

func Attack():
	if object != null:
		$Sprite.global_position = $Sprite.global_position.move_toward(object.position, 15)
		if $Sprite.global_position == object.global_position:
			pass#object.TakeDamage()
			canAttack = false
			stateControl = state.RECOIL
			print("voltou")
			yield(get_tree().create_timer(1), "timeout")
			canAttack = true

func _on_PlayerAreaCheck_body_entered(body):
	if "Player" in body.name:
		stateControl = state.FOLLOW
		object = body

func _on_PlayerAreaCheck_body_exited(body):
	if "Player" in body.name:
		stateControl = state.BACK
		object = null

func _on_AttackArea_body_entered(body):
	if "Player" in body.name:
		print("atacando")
		stateControl = state.ATTACK

func _on_AttackArea_body_exited(body):
	if "Player" in body.name:
		stateControl = state.FOLLOW
