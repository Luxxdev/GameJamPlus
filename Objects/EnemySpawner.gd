extends Node2D


var enemy = load("res://Objects/EnemyPath.tscn")
onready var areaSize = $Area2D/CollisionShape2D.get_shape().get_extents()
onready var timer = $SpawnTimer
onready var enemyArea = $EnemyArea
var timerDefaultWaitTime
var canSpawn = false
export var maxEnemies = 5
onready var enemies = $Enemies

func _ready():
	timer.start()

func _on_SpawnTimer_timeout():
#	timerDefaultWaitTime = rand_range(5,10)
	set_spawn_position()
	yield(get_tree().create_timer(0.2), "timeout")
	if canSpawn:
		var enemy_instance = enemy.instance()
		enemies.add_child(enemy_instance)
		enemy_instance.global_position = enemyArea.global_position
		pass
		

func set_spawn_position():
	enemyArea.global_position = to_global(Vector2(rand_range(-areaSize.x, areaSize.x), rand_range(-areaSize.y, areaSize.y)))
	yield(get_tree().create_timer(0.1), "timeout")
	if enemyArea.get_overlapping_bodies() != []:
		set_spawn_position()
		canSpawn = false
	else:
		canSpawn = true
