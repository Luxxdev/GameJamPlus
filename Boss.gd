extends Node2D

var player
var fightStarted
var currentState = state.COOLDOWN
onready var enemySpawner = $BossBody/EnemySpawner
var count = 0
var cooldown = 5
var life = 10
onready var sprite = $BossBody/Sprite
var playerOnDamageArea = false
export(PackedScene) var Bullet

func _ready():
	set_process(false)

enum state{
	ATTACK,
	ATTACK2,
	COOLDOWN,
	SPAWN,
	PREPARE
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
	$BossBody.visible = true
	set_process(true)

func _process(delta):
	match currentState:
		state.ATTACK:
			print("atk1")
			cooldown = 1
#			Shoot()
			currentState = state.COOLDOWN
		state.ATTACK2:
			print("atk2")
			cooldown = 2
			currentState = state.COOLDOWN
		state.SPAWN:
			print("spawn")
			enemySpawner.set_spawn_position()
			cooldown = 3
			currentState = state.COOLDOWN
		state.COOLDOWN:
			count += delta
			if count > cooldown:
				pass
				currentState = state.ATTACK
			
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
	var dir = Vector2.RIGHT
	for i in range(8):
		var bulletInstance = Bullet.instance()
		bulletInstance.rotation = dir.rotated(45*i)
		bulletInstance.global_position = $Position2D.global_position
		bulletInstance.velocity = 100
		get_parent().get_parent().get_parent().add_child(bulletInstance)
	
func Atack(): #porrada?
	pass
	
func TakeDamage(dir):
	life -= 1
	print(life)
	if life <= 0:
		queue_free()

func _on_DamageArea_body_entered(body):
	if "Player" in body.name:
		playerOnDamageArea = true

func _on_DamageArea_body_exited(body):
	if "Player" in body.name:
		playerOnDamageArea = false
