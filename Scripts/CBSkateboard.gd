extends CharacterBody3D

const ACCEL = 0.2
const AIR_ACCEL = 0.1
const MAX_SPEED = 4.0
const RIDE_SPEED = 4.0
const JUMP_VELOCITY = 4.5

var speed = 0.0
var accel = 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	
	if is_on_floor():
		accel = ACCEL
	else:
		accel = AIR_ACCEL
	
	if direction > 0:
		speed += accel
	elif direction < 0:
		speed -= accel
	else:
		if speed < 0:
			speed += accel
			if speed > 0:
				speed = 0
		elif speed > 0:
			speed -= accel
			if speed < 0:
				speed = 0
	
	if speed > MAX_SPEED:
		speed = MAX_SPEED
	elif speed < -MAX_SPEED:
		speed = -MAX_SPEED
	
	velocity.x = RIDE_SPEED
	velocity.z = speed

	move_and_slide()
