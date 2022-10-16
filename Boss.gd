extends Node2D

var player
var fightStarted
var currentState = state.COOLDOWN
onready var enemySpawner = $BossBody/EnemySpawner
var count = 0
var cooldown = 5

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
				currentState = state.SPAWN
			
	if currentState != state.COOLDOWN:
		count = 0
