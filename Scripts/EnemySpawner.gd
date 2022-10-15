extends Node2D


onready var enemy = load("res://Objects/EnemyPath.tscn")
onready var areaSize = $Area2D/CollisionShape2D.get_shape().get_extents()
onready var timer = $SpawnTimer
onready var enemyArea = $EnemyArea
var timerDefaultWaitTime
var canSpawn = true
export var maxEnemies = 5
export var spawnFrequency = 5.0
onready var enemies = $Enemies
export var spawnPositions = []
var enemyInPosition = []
onready var visibilityNotifier = $VisibilityNotifier2D

func _ready():
	for i in $EnemyAreas.get_children():
		spawnPositions.append(i)
	timer.wait_time = spawnFrequency
	spawnPositions.shuffle()
	for i in range (spawnPositions.size()):
		enemyInPosition.append(null)
#		SpawnEnemy(i)
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
	enemy_instance.global_position = pos.global_position
	pass

func set_spawn_position():
	enemyInPosition.shuffle()
	for i in range(enemyInPosition.size()):
		if enemyInPosition[i] == null:
			SpawnEnemy(spawnPositions[i])
#	enemyArea.global_position = to_global(Vector2(rand_range(-areaSize.x, areaSize.x), rand_range(-areaSize.y, areaSize.y)))
#	yield(get_tree().create_timer(0.01), "timeout")
#	if enemyArea.get_overlapping_bodies() != []:
#		set_spawn_position()
#		canSpawn = false
#	else:
#		canSpawn = true

func _on_VisibilityNotifier2D_screen_entered():
	canSpawn = false
	pass # Replace with function body.

func _on_VisibilityNotifier2D_screen_exited():
	canSpawn = true
	pass # Replace with function body.
