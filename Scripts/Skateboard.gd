extends CharacterBody3D

const ACCEL = 4.0
const AIR_ACCEL = 2.0
const RIDE_SPEED = 8.0
const MAX_TURN_SPEED = 2.0
const JUMP_VELOCITY = 7.0
const TRICK_SPEED = 15.0

var lastRotation = 0
var _rotation = 0
var turnSpeed = 0.0
var accel = 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var jump = false
var jumping = false
var kickFlip = false

#variables that are set in the ready function
var skateboard
var defaultBoardRotation
var animationPlayer
var rayCastFront

func _ready():
	skateboard = $Skateboard
	defaultBoardRotation = skateboard.rotation
	animationPlayer = get_node("Skateboard/AnimationPlayer")
	animationPlayer.set_assigned_animation("Ollie")
	rayCastFront = $RayCastFront

func _physics_process(delta):
	setAcceleration()
	handleInput()
	setTurnSpeed(delta)
	applyRotation(delta)
	applyGravity(delta)
	jumpLogic()
	trickLogic(delta)
	moveLogic()
	animate()
	move_and_slide()
	
func setAcceleration():
	if not is_on_floor():
		accel = AIR_ACCEL
	else:
		accel = ACCEL
		jumping = false

func handleInput():
	lastRotation = _rotation
	if OS.get_name() == "Android":
		androidControls()
	else:
		windowsControls()

func _input(event):
	if event is InputEventScreenTouch:
		jump = is_on_floor() and event.is_pressed()

func androidControls():
	var orient = Input.get_accelerometer().normalized().x
	if orient > 0.1:
		_rotation = -1
	elif orient < -0.1:
		_rotation = 1
	else:
		_rotation = 0
		
func windowsControls():
	_rotation = Input.get_action_strength("player_left") - Input.get_action_strength("player_right")
	jump = is_on_floor() and Input.is_action_just_pressed("player_jump")
	if not is_on_floor() and Input.is_action_just_pressed("player_jump"):
		kickFlip = true

func setTurnSpeed(delta):
	if _rotation == lastRotation:
		turnSpeed += accel * delta
		if turnSpeed > MAX_TURN_SPEED:
			turnSpeed = MAX_TURN_SPEED
	else:
		turnSpeed = 0.0
	
func applyRotation(delta):
	rotate_y((_rotation * turnSpeed) * delta)

func applyGravity(delta):
	velocity.y -= gravity * delta

func jumpLogic():
	if jump:
		velocity.y = JUMP_VELOCITY
		jumping = true
		
func trickLogic(delta):
	if not is_on_floor() and kickFlip:
		doAKickFlip(delta)
	else:
		kickFlip = false
		skateboard.rotation = defaultBoardRotation
		
func doAKickFlip(delta):
	skateboard.rotation.x += TRICK_SPEED * delta
	if skateboard.rotation_degrees.x > 360:
		skateboard.rotation_degrees.x = 0
		kickFlip = false
		
func moveLogic():
	if rotation.x >= 1 and velocity.y < 0:
		rotation.x = -rotation.x
	var normal = rayCastFront.get_collision_normal()
	var xForm = alignWithY(global_transform, normal)
	global_transform = global_transform.interpolate_with(xForm, 0.2)
	var heading = -transform.basis.z * RIDE_SPEED
	velocity.x = heading.x
	velocity.z = heading.z
	if is_on_floor():
		velocity.y += heading.y
	
func alignWithY(xForm, newY):
	xForm.basis.y = newY
	xForm.basis.x = -xForm.basis.z.cross(newY)
	xForm.basis = xForm.basis.orthonormalized()
	return xForm
	
func animate():
	if jumping:
		if (animationPlayer.get_assigned_animation() != "Ollie" or 
				animationPlayer.get_current_animation_position() != animationPlayer.get_current_animation_length()):
				animationPlayer.play("Ollie")
	else:
		if animationPlayer.get_assigned_animation() == "Ollie":
			animationPlayer.set_assigned_animation("TurnRight")
		if _rotation < 0:
			if (animationPlayer.get_assigned_animation() != "TurnRight" or 
				animationPlayer.get_current_animation_position() != animationPlayer.get_current_animation_length()):
				animationPlayer.play("TurnRight")
		elif _rotation > 0:
			if (animationPlayer.get_assigned_animation() != "TurnLeft" or 
				animationPlayer.get_current_animation_position() != animationPlayer.get_current_animation_length()):
				animationPlayer.play("TurnLeft")
		elif animationPlayer.get_assigned_animation() != "Ollie":
			if animationPlayer.get_current_animation_position() != 0:
				animationPlayer.play_backwards(animationPlayer.get_assigned_animation())
