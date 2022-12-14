extends KinematicBody2D
class_name Player

const UP = Vector2(0,-1)
var motion = Vector2()
var gravity = 20
var maxGravity = 300
var canMove = true
var canPlay = true
var inputEnabled = true
var moveDir = Vector2(-1,0)
var noMovementInput = true
var walking = false
var acceleration = 100
var maxSpeed = 100
var canJump = true
var justJumped = false
var jumpHeight = 300
#var airAcceleration = 50
var dashDirection
var dashSpeed = 750
var canDash = true
var isDashing = false
var invulnerable = false
var dashTarget = []
var stunned = false
var falling = false
var lastXMovement = 1
var reducedGravity = 5
var normalGravity = 20
#var currentCoyote = 0
#var maxCoyote = 0.2
var jumpDirection = Vector2(0,-1)
var wallDirection = 0
var maxCameraOffset = 100
var health = 10
const maxHealth = 10
signal healthChanged
onready var tween = $Tween
onready var sprite = $Sprite
onready var animPlayer = $AnimationPlayer
onready var wallraycast = $WallRaycast
onready var raycastSide = $WallRaycast/RayCastSides
onready var raycastSide2 = $WallRaycast/RayCastSides2
onready var raycastUp = $RayCastUp
onready var dashTimer = $DashTimer
onready var dashCooldown = $DashCooldown
onready var attackAreaColl = $Sprite/AttackArea/CollisionShape2D
var camera

func _ready():
	camera = get_parent().get_node("Player/CameraReal")

func _physics_process(_delta):
	#motion.y = min(motion.y+gravity, maxGravity)
#	if !is_on_floor():
#		currentCoyote += _delta
#		if currentCoyote > maxCoyote:
#			canJump = false
	moveDir = Vector2(0,0)
	if Input.is_action_pressed("ui_right") and !falling and inputEnabled:
#		camera.offset.x = min(camera.offset.x + _delta*60, maxCameraOffset)
		moveDir.x = 1
		move()
	elif Input.is_action_pressed("ui_left") and !falling and inputEnabled:
#		camera.offset.x = max(camera.offset.x - _delta*60, -maxCameraOffset)		
		moveDir.x = -1
		move()
#	else:
#		if camera.offset.x > 0:
#			camera.offset.x = max(camera.offset.x - _delta*200, 0)
#		if camera.offset.x < 0:
#			camera.offset.x = min(camera.offset.x + _delta*200, 0)
			
	if Input.is_action_pressed("ui_up") and _check_is_valid_wall() and !falling and inputEnabled:
		camera.offset.y = max(camera.offset.y - _delta*60, -maxCameraOffset)
		moveDir.y = -1
#		moveDir.x = 0
		move()
	elif Input.is_action_pressed("ui_down") and _check_is_valid_wall() and !falling and inputEnabled:
		camera.offset.y = min(camera.offset.y + _delta*60, maxCameraOffset)
		moveDir.y = 1
#		moveDir.x = 0
		move()
	else:
		if camera.offset.y > 0:
			camera.offset.y = max(camera.offset.y - _delta*200, 0)
		if camera.offset.y < 0:
			camera.offset.y = min(camera.offset.y + _delta*200, 0)
		
			
		
	
	if motion.x > 0.1:
		lastXMovement = 1
	elif motion.x < -0.1:
		lastXMovement = -1
	
		
	if moveDir == Vector2(0,0):
#		if is_on_floor():
#			animPlayer.play("Idle")
#		elif !is_on_floor() and !_check_is_valid_wall():
#			animPlayer.play("Jump")
		noMovementInput = true
		walking = false
	
	if _check_is_valid_wall() or raycastUp.is_colliding():
		canJump = true
		canDash = true
#		currentCoyote = 0
		if moveDir.y == -1:
			if motion.y > 0:
				motion.y = 0
		elif moveDir.y == 1:
			if motion.y < 0:
				motion.y = 0
		elif moveDir.x != 0:
			if motion.y < 0:
				motion.y = 0
			if motion.y > 0:
				motion.y = 0
		else:
			if motion.y > 0:
				motion.y -= gravity
			elif motion.y < 0:
				motion.y += gravity
		if !stunned and falling:
			falling = false
	else:
		motion.y += gravity
		sprite.flip_v = false
		
	if Input.is_action_just_pressed("Dash") and canDash and !stunned and dashCooldown.is_stopped():
		Dash()
	if Input.is_action_just_pressed("Jump") and !stunned and inputEnabled:
		Jump()
	if is_on_floor() or raycastUp.is_colliding():
		canJump = true
		canDash = true
#		currentCoyote = 0
		sprite.flip_v = false
		if (moveDir.x == 0):
			motion.x = lerp(motion.x, 0, 0.2)
		if raycastUp.is_colliding():
			jumpDirection.y = 0.5
			motion.y -= 1
		else:
			sprite.rotation_degrees = 0
		if !stunned and falling:
			falling = false
			
	else:
		sprite.flip_h = false
		sprite.rotation_degrees = 0
		jumpDirection.y = -1
	
	if _check_is_valid_wall() and noMovementInput:
		motion.y = lerp(motion.y, 0, 0.2)
	if !dashTimer.is_stopped():
		motion = move_and_slide(dashDirection, UP)
	else:
		motion = move_and_slide(motion, UP)
	HandleAnimations()
	
func move():
#	if invertControls:
#		move_dir *= -1
	if moveDir.x > 0 and motion.x < maxSpeed:
		motion.x = min(motion.x+acceleration, maxSpeed)
		sprite.flip_h = false
	elif moveDir.x < 0 and motion.x > -maxSpeed:
		motion.x = max(motion.x-acceleration, -maxSpeed)
		sprite.flip_h = true
	if moveDir.y > 0:
		motion.y = min(motion.y+acceleration, maxSpeed)
		sprite.flip_v = true
		if wallDirection > 0:
			sprite.flip_h = true
		elif wallDirection < 1:
			sprite.flip_h = false
	elif moveDir.y < 0:
		motion.y = max(motion.y-acceleration, -maxSpeed)
		sprite.flip_v = false
		if wallDirection > 0:
			sprite.flip_h = true
		elif wallDirection < 1:
			sprite.flip_h = false
	noMovementInput = false
	walking = true

func Jump():
	if canJump:
		if _check_is_valid_wall():
			jumpDirection.x = wallDirection
			motion.x = maxSpeed*5*(jumpDirection.x)
		else:
			jumpDirection.x = moveDir.x * 2
			motion.x = maxSpeed*(jumpDirection.x)
		motion.y = jumpDirection.y * jumpHeight
		#$JumpSound.play()
		falling = false
		canDash = true
		yield(get_tree().create_timer(0.01), "timeout")
		canJump = false
		yield(get_tree().create_timer(0.2), "timeout")
		motion.x = motion.x/4
#		acceleration = airAcceleration
#		justJumped = true
#		yield(get_tree().create_timer(maxCoyoteTime), "timeout") 
#		justJumped = false

func _check_is_valid_wall():
	if falling and stunned:
		return false
	for raycasts in wallraycast.get_children():
		if raycasts.is_colliding():
			if raycasts.get_collision_point().x > global_position.x:
				wallDirection = -1
			elif raycasts.get_collision_point().x < global_position.x:
				wallDirection = 1
			return true
	wallDirection = 0
	return false
	
func GetDirection():
	var direction = Vector2(0,0)
#	if dashTarget == []:
	direction.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	direction = direction.clamped(1)
	if direction.x != 0 and direction.y != 0:
		return direction
		
	elif direction == Vector2(0,0) and dashTarget == []:
		if lastXMovement == 1:
			direction.x = 1
		elif lastXMovement == -1:
			direction.x = -1
			
	elif dashTarget != []:
		var temp = []
		for i in dashTarget:
			temp.append([i, i.global_position.distance_to(global_position)])
		temp.sort_custom(MyCustomSorter, "sort_ascending_by_second_element")
		if direction.x == 0:
			direction.x = (temp[0][0].global_position - global_position).normalized().x
		if direction.y == 0:
			direction.y = (temp[0][0].global_position - global_position).normalized().y
	return direction
#	else:
#		var temp = []
#		for i in dashTarget:
#			temp.append([i, i.global_position.distance_to(global_position)])
#		temp.sort_custom(MyCustomSorter, "sort_ascending_by_second_element")
#		direction = (temp[0][0].global_position - global_position).normalized()
#	return direction

class MyCustomSorter:
	static func sort_ascending_by_second_element(a, b):
		return a[1] < b[1]
			
func TakeDamage(dir, boss = false):
	if invulnerable and !boss:
		pass
	else:
		print("tomei")
		sprite.self_modulate = Color(1,0,0,1)
		if _check_is_valid_wall():
			dir *= -1
		motion = Vector2(0,0)
		isDashing = false
		$BloodShred.visible = false
		dashTimer.stop()
		stunned = true
		falling = true
		health -= 1
		motion.y = 300 * jumpDirection.y
		motion.x = 100 * dir
		invulnerable = true
		emit_signal("healthChanged", true)
		yield(get_tree().create_timer(1), "timeout")
		sprite.self_modulate = Color(1,1,1,1)		
		stunned = false
		canJump = true
		invulnerable = false
		if health <= 0:
			get_tree().change_scene("res://Scenes/GameOver.tscn")

func Dash():
	dashDirection = GetDirection() * dashSpeed
	$BloodShred.rotation = dashDirection.angle()
	$BloodShred.modulate = Color(1,1,1,1)
	$BloodShred.visible = true
	animPlayer.play("Attack")
	dashTimer.start()
	dashCooldown.start()
	isDashing = true
	attackAreaColl.disabled = false
	#print(lastXMovement)
	gravity = reducedGravity
	invulnerable = true
	if lastXMovement == -1:
		pass
	elif lastXMovement == 1:
		pass
	yield(get_tree().create_timer(0.01), "timeout")
	canDash = false
	canJump = false #IF n??o acertar um inimigo
#	$Particles2D.emitting = false
	yield(get_tree().create_timer(0.3), "timeout")
	tween.interpolate_property($BloodShred,"modulate",Color(1,1,1,1),Color(1,1,1,0),0.1,Tween.TRANS_QUAD,Tween.EASE_IN)
	tween.start()
	invulnerable = false
	yield(get_tree().create_timer(0.3), "timeout")
	gravity = normalGravity

func HandleAnimations():
	sprite.rotation_degrees = 0
	if isDashing:
		animPlayer.play("Attack")
	elif Input.is_action_pressed("ui_right") and is_on_floor():
		animPlayer.play("Run")
		sprite.flip_h = false
	elif Input.is_action_pressed("ui_left") and is_on_floor():
		animPlayer.play("Run")
		sprite.flip_h = true
	elif is_on_floor():
		animPlayer.play("Idle")
		if lastXMovement > 0:
			sprite.flip_h = false
		elif lastXMovement < 0:
			sprite.flip_h = true
			
	elif _check_is_valid_wall():
		if wallDirection == -1:
			sprite.flip_h = false
			animPlayer.play("Climb")
		elif wallDirection == 1:
			sprite.flip_h = true
			animPlayer.play("Climb")
			
		if Input.is_action_pressed("ui_down"):
			sprite.flip_v = true
			animPlayer.play("Climb")
		elif Input.is_action_pressed("ui_up"):
			animPlayer.play("Climb")
			sprite.flip_v = false
		else:
			yield(get_tree().create_timer(0.01), "timeout")
			animPlayer.stop()
	elif raycastUp.is_colliding():
		if moveDir.x > 0 || lastXMovement == 1:
				sprite.rotation_degrees = 90
				sprite.flip_h = true
		elif moveDir.x < 0 || lastXMovement == -1:
				sprite.rotation_degrees = -90
				sprite.flip_h = false
		animPlayer.play("Climb")	
		if Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right"):
			animPlayer.play("Climb")
		else:
			yield(get_tree().create_timer(0.01), "timeout")
			animPlayer.stop()
	else:
		animPlayer.play("Jump")
		sprite.flip_v = false
		sprite.rotation_degrees = 0
		if motion.x > 0:
			sprite.flip_h = false
		elif motion.x < 0:
			sprite.flip_h = true
		elif lastXMovement == 1:
			sprite.flip_h = false
		elif lastXMovement == -1:
			sprite.flip_h = true
		

func _on_DashTimer_timeout():
	isDashing = false
	attackAreaColl.disabled = true
	motion = Vector2(0,0)
	pass # Replace with function body.

func _on_AttackArea_area_entered(area):
	#print(area.get_groups())
	if area.is_in_group("DashTarget"):
		if area.is_in_group("MovingEnemy"):
			area.get_parent().get_parent().get_parent().TakeDamage(dashDirection)
			if health < maxHealth:
				emit_signal("healthChanged", false)
		elif area.is_in_group("Boss"):
			area.get_parent().get_parent().TakeDamage(dashDirection)
			Dash()
			dashDirection = -dashDirection
		else:
#			if area.get_parent().name == "ShootingEnemy" and health < maxHealth:
#				health += 1
#				emit_signal("healthChanged")
			area.get_parent().TakeDamage(dashDirection)
		yield(get_tree().create_timer(dashTimer.wait_time), "timeout")
		canDash = true
		canJump = true

func _on_DetectionArea_area_entered(area):
	if area.is_in_group("DashTarget"):
		dashTarget.append(area)

func _on_DetectionArea_area_exited(area):
	if area.is_in_group("DashTarget"):
		dashTarget.erase(area)

