extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
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
var acceleration = 75
var maxSpeed = 150
var canJump = true
var justJumped = false
var jumpHeight = 500
#var airAcceleration = 50
var dashDirection
var dashSpeed = 2000
var canDash = true
#var currentCoyote = 0
#var maxCoyote = 0.2
var jumpDirection = Vector2(0,-1)
var wallDirection = 0
onready var sprite = $Sprite
onready var animPlayer = $AnimationPlayer
onready var wallraycast = $WallRaycast
onready var raycastSide = $WallRaycast/RayCastSides
onready var raycastSide2 = $WallRaycast/RayCastSides2
onready var raycastUp = $RayCastUp
onready var dashTimer = $DashTimer

func _physics_process(_delta):
	#motion.y = min(motion.y+gravity, maxGravity)
#	if !is_on_floor():
#		currentCoyote += _delta
#		if currentCoyote > maxCoyote:
#			canJump = false
	moveDir = Vector2(0,0)
#	if !canMove:
#		if is_on_floor():
#			animPlayer.play("Idle")
#		else:
#			animPlayer.play("Fall")
	if Input.is_action_pressed("ui_right") and inputEnabled:
		moveDir.x = 1
		move()
	elif Input.is_action_pressed("ui_left") and inputEnabled:
		moveDir.x = -1
		move()
	if Input.is_action_pressed("ui_up") and _check_is_valid_wall() and inputEnabled:
		moveDir.y = -1
#		moveDir.x = 0
		move()
	elif Input.is_action_pressed("ui_down") and _check_is_valid_wall() and inputEnabled:
		moveDir.y = 1
#		moveDir.x = 0
		move()
		
	if moveDir == Vector2(0,0):
		if is_on_floor():
			animPlayer.play("Idle")
		else:
			animPlayer.play("Fall")
			
		noMovementInput = true
		walking = false
#		elif _check_is_valid_wall():
#			animPlayer.play("IdleWall")
	
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
	else:
		motion.y += gravity
		sprite.flip_v = false
		
	if Input.is_action_just_pressed("Dash") and canDash:
		Dash()
	if Input.is_action_just_pressed("Jump") and inputEnabled:
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
	else:
		jumpDirection.y = -1
		
	
	if _check_is_valid_wall() and noMovementInput:
		motion.y = lerp(motion.y, 0, 0.2)
	if !dashTimer.is_stopped():
		motion = move_and_slide(dashDirection, UP)
	else:
		motion = move_and_slide(motion, UP)

func move():
#	if invertControls:
#		move_dir *= -1
	if moveDir.x > 0 and motion.x < maxSpeed:
		motion.x = min(motion.x+acceleration, maxSpeed)
		sprite.flip_h = true
		animPlayer.play("Run")
	elif moveDir.x < 0 and motion.x > -maxSpeed:
		motion.x = max(motion.x-acceleration, -maxSpeed)
		sprite.flip_h = false
		animPlayer.play("Run")
	if moveDir.y > 0:
		motion.y = min(motion.y+acceleration, maxSpeed)
		animPlayer.play("Climb")
		#rodar o player na parede? 90º
		sprite.flip_v = true
	elif moveDir.y < 0:
		motion.y = max(motion.y-acceleration, -maxSpeed)
		sprite.flip_v = false
		animPlayer.play("Climb")
		# rodar -90º?
	noMovementInput = false
	walking = true

func Jump():
	if canJump:
		if _check_is_valid_wall():
			print(wallDirection)
			jumpDirection.x = wallDirection
			motion.x = maxSpeed*3*(jumpDirection.x)
		else:
			jumpDirection.x = moveDir.x * 2
			motion.x = maxSpeed*(jumpDirection.x)
			print(jumpDirection.x)
			
		motion.y = jumpDirection.y * jumpHeight 
		#$JumpSound.play()
		canJump = false
		canDash = true
#		acceleration = airAcceleration
#		justJumped = true
#		yield(get_tree().create_timer(maxCoyoteTime), "timeout") 
#		justJumped = false

func _check_is_valid_wall():
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
	direction.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	direction = direction.clamped(1)
	if(direction == Vector2(0,0)):
		if(sprite.flip_h):
			direction.x = 1
		else:
			direction.x = -1
	return direction
	
func Dash():
	dashDirection = GetDirection() * dashSpeed
	dashTimer.start()
	yield(get_tree().create_timer(0.05), "timeout")
	canDash = false
	canJump = false #IF não acertar um inimigo


func _on_DashTimer_timeout():
	motion = Vector2(0,0)
	pass # Replace with function body.
