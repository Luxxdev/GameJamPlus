extends Node2D

var player
var fightStarted
var currentState = state.COOLDOWN
onready var enemySpawner = $BossBody/EnemySpawner
var count = 0
var cooldown = 2 
var life = 20
signal healthChanged
onready var sprite = $BossBody/BossHead
onready var bossBody = $BossBody
var playerOnDamageArea = false
export(PackedScene) var Bullet
onready var bulletSpawnPoint = $BossBody/ShootingPoint/Position2D
var moveDirection = 0
var lowLifeMult = 1
var lowLife
var veryLowLife
var shootCount = 0



func _ready():
	set_process(false)
	lowLife = life/2
	veryLowLife = life/4

enum state{
	COOLDOWN,
	ATTACK,
	ATTACK2,
	SPAWN,
}

func _on_StartFightArea_body_entered(body):
	if "Player" in body.name:
		player = body
		StartFight()

func StartFight():
	fightStarted = true
	for i in $ExitBlockers.get_children():
		i.get_child(1).visible = true
		i.get_node("CollisionShape2D").set_deferred("disabled", false)
	visible = true
	set_process(true)

func _process(delta):
	match currentState:
		state.ATTACK:
			print("atk1")
			$BossBody/BossHead/BossLHand.play("Cast")
			$BossBody/BossHead/BossRHand.play("Cast")
			cooldown = 4/lowLifeMult
			Shoot()
			currentState = state.COOLDOWN
			if life < veryLowLife:
				yield(get_tree().create_timer(0.5), "timeout")
				Shoot()
		state.ATTACK2:
			print("atk2")
			var coquecoisa = randi() % 2
			if coquecoisa == 0:
				$AnimationPlayer.play("SwipeL")
			else:
				$AnimationPlayer.play("SwipeR")
			cooldown = 4/lowLifeMult
			currentState = state.COOLDOWN
		state.SPAWN:
			print("spawn")
			$BossBody/BossHead/BossLHand.play("SpawnL")
			$BossBody/BossHead/BossRHand.play("SpawnR")
			if enemySpawner.enemies.get_child_count() != 0:
				cooldown = 0
			else:
				enemySpawner.set_spawn_position()
				cooldown = 4/lowLifeMult
			currentState = state.COOLDOWN
		state.COOLDOWN:
#			$BossBody/BossHead/BossLHand.play("Idle")
#			$BossBody/BossHead/BossRHand.play("Idle")
			count += delta
			if count > cooldown:
#				currentState = state.ATTACK2
				currentState = randi() % 3 + 1
	
	if bossBody.global_position.x - player.global_position.x > 50:
		moveDirection = -1
	elif bossBody.global_position.x - player.global_position.x < -50:
		moveDirection = 1
	else:
		moveDirection = 0
	
	bossBody.position.x += 50*lowLifeMult*delta*moveDirection
	
	if currentState != state.COOLDOWN:
		count = 0
	
	if playerOnDamageArea and !player.isDashing:
		var dir
		if sprite.global_position.x - player.global_position.x > 0:
			dir = -1
		else:
			dir = 1
		player.TakeDamage(dir, true)
		playerOnDamageArea = false

func Shoot(): # jogar oito bolas de fogo
	var dir
	if shootCount == 0:
		shootCount += 1
		dir = 0
	elif shootCount == 1:
		shootCount -= 1
		dir = 22.5
	
	for i in range(8):
		var bulletInstance = Bullet.instance()
		bulletSpawnPoint.get_parent().rotation_degrees = 45*i + dir
		bulletInstance.isBoss = true
		bulletInstance.rotation_degrees = bulletSpawnPoint.get_parent().rotation_degrees
		bulletInstance.global_position = bulletSpawnPoint.global_position
		bulletInstance.velocity = Vector2(cos(bulletSpawnPoint.get_parent().rotation), sin(bulletSpawnPoint.get_parent().rotation))
		get_parent().add_child(bulletInstance)
	
func Atack(): #porrada?
	pass
	
func TakeDamage(dir):
	life -= 1
	if life < lowLife:
		lowLifeMult = 1.5
	if life < veryLowLife:
		lowLifeMult = 2
	emit_signal("healthChanged")
	if life <= 0:
		queue_free()
		get_tree().change_scene("res://Scenes/Victory.tscn")

func _on_DamageArea_body_entered(body):
	if "Player" in body.name:
		playerOnDamageArea = true

func _on_DamageArea_body_exited(body):
	if "Player" in body.name:
		playerOnDamageArea = false

func _on_BossRHand_animation_finished():
	if $BossBody/BossHead/BossRHand.animation != "Swipe":
		$BossBody/BossHead/BossRHand.play("Idle")


func _on_BossLHand_animation_finished():
	if $BossBody/BossHead/BossLHand.animation != "Swipe":
		$BossBody/BossHead/BossLHand.play("Idle")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "SwipeL":
		$BossBody/BossHead/BossLHand.play("Idle")
	else:
		$BossBody/BossHead/BossRHand.play("Idle")
