extends Node2D


onready var enemy = load("res://Objects/MovingEnemy.tscn")
onready var areaSize = $Area2D/CollisionShape2D.get_shape().get_extents()
onready var timer = $SpawnTimer
#onready var enemyArea = $EnemyAreas/EnemyArea
var timerDefaultWaitTime
var canSpawn = true
export var maxEnemies = 5
export var spawnFrequency = 5.0
onready var enemies = $Enemies
var spawnPositions = []
var enemyInPosition = []
onready var visibilityNotifier = $VisibilityNotifier2D

func _ready():
	for i in range($EnemyAreas.get_child_count()):
		spawnPositions.append($EnemyAreas.get_child(i))
		enemyInPosition.append(i)
	timer.wait_time = spawnFrequency
	for i in range (spawnPositions.size()):
		SpawnEnemy(i)
	timer.start()

func _on_SpawnTimer_timeout():
	timer.start()
	if enemies.get_child_count() >= maxEnemies:
		pass
	else:
		if canSpawn:
			set_spawn_position()
#		yield(get_tree().create_timer(0.2), "timeout")
#		if canSpawn:
#			SpawnEnemy()

func SpawnEnemy(pos):
	var enemy_instance = enemy.instance()
	enemies.add_child(enemy_instance)
	enemyInPosition[pos] = pos
	enemy_instance.global_position = spawnPositions[pos].global_position
	enemy_instance.positionInSpawner = pos
	enemy_instance.spawnerRef = self

func set_spawn_position():
	for i in range(enemyInPosition.size()):
		if enemyInPosition[i] == null:
			SpawnEnemy(i)
			
#	enemyArea.global_position = to_global(Vector2(rand_range(-areaSize.x, areaSize.x), rand_range(-areaSize.y, areaSize.y)))
#	yield(get_tree().create_timer(0.01), "timeout")
#	if enemyArea.get_overlapping_bodies() != []:
#		set_spawn_position()
#		canSpawn = false
#	else:
#		canSpawn = true

func _on_VisibilityNotifier2D_screen_entered():
	canSpawn = false
	timer.set_paused(true)
	pass # Replace with function body.

func _on_VisibilityNotifier2D_screen_exited():
	canSpawn = true
	timer.set_paused(false)
	pass # Replace with function body.
