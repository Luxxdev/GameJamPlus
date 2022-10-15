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
var friction = true
var walking = false
var acceleration = 75
var maxSpeed = 150
var canJump = true
var justJumped = false
var jumpHeight = -500
var airAcceleration = 50
onready var sprite = $Sprite
onready var animPlayer = $AnimationPlayer
onready var wallraycast = $WallRaycast
onready var raycastSide = $WallRaycast/RayCastSides
onready var raycastSide2 = $WallRaycast/RayCastSides2
onready var raycastUp = $RayCastUp

func _physics_process(delta):
	#motion.y = min(motion.y+gravity, maxGravity)
	if !canMove:
		if is_on_floor():
			animPlayer.play("Idle")
		else:
			animPlayer.play("Fall")
	
	elif Input.is_action_pressed("ui_right") and inputEnabled:
		moveDir.x = 1
		move()
	elif Input.is_action_pressed("ui_left") and inputEnabled:
		moveDir.x = -1
		move()
	elif Input.is_action_pressed("ui_up") and _check_is_valid_wall() and inputEnabled:
		moveDir.y = -1
		moveDir.x = 0
		move()
	elif Input.is_action_pressed("ui_down") and _check_is_valid_wall() and inputEnabled:
		moveDir.y = 1
		moveDir.x = 0
		move()
	else:
		animPlayer.play("Idle")
		friction = true
		walking = false
	
	if Input.is_action_pressed("Jump") and inputEnabled:
		Jump()
	
	if _check_is_valid_wall() or raycastUp.is_colliding():
		canJump = true
		if !walking:
			motion.y = 0
		#motion.y += 0
	else:
		motion.y += gravity
		sprite.flip_v = false
	
	if is_on_floor() or raycastUp.is_colliding():
		canJump = true
		sprite.flip_v = false
		if (friction):
			motion.x = lerp(motion.x, 0, 0.2)
	
	if _check_is_valid_wall() and friction:
		motion.y = lerp(motion.y, 0, 0.2)
	motion = move_and_slide(motion, UP)

func move():
#	if invertControls:
#		move_dir *= -1
	if moveDir.x > 0:
		motion.x = min(motion.x+acceleration, maxSpeed)
		sprite.flip_h = true
		animPlayer.play("Run")
	elif moveDir.x < 0:
		motion.x = max(motion.x-acceleration, -maxSpeed)
		sprite.flip_h = false
		animPlayer.play("Run")
	elif moveDir.y > 0:
		motion.y = min(motion.y+acceleration, maxSpeed)
		animPlayer.play("Climb")
		#rodar o player na parede? 90º
		sprite.flip_v = true
	elif moveDir.y < 0:
		motion.y = max(motion.y-acceleration, -maxSpeed)
		sprite.flip_v = false
		animPlayer.play("Climb")
		# rodar -90º?
	friction = false
	walking = true

func Jump():
	if canJump:
		motion.y = jumpHeight 
		if _check_is_valid_wall() && walking:
			motion.x = maxSpeed*15*(moveDir.x)
		#$JumpSound.play()
		canJump = false
		acceleration = airAcceleration
#		justJumped = true
#		yield(get_tree().create_timer(maxCoyoteTime), "timeout") 
#		justJumped = false

func _check_is_valid_wall():
	for raycasts in wallraycast.get_children():
		if raycasts.is_colliding():
			return true
	return false

#func play_animation(animation):
#	if can_play and current_anim != animation:
#		current_anim = animation
#		AnimPlayer.play(animation)
