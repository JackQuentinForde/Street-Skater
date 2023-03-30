extends CharacterBody3D

const ACCEL = 0.5
const AIR_ACCEL = 0.25
const MIN_SPEED = 2.0
const MAX_SPEED = 2.0
const JUMP_VELOCITY = 5.0

var direction = Vector3(1, 0, 0)
var _rotation = 0

var speed = 0.0
var accel = 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var jumping = false

#variables that are set in the ready function 
var animationPlayer

func _ready():
	animationPlayer = get_node("Skateboard/AnimationPlayer")

func _physics_process(delta):	
	if not is_on_floor():
		accel = AIR_ACCEL
	else:
		accel = ACCEL

	_rotation = Input.get_action_strength("player_left") - Input.get_action_strength("player_right")

	rotate_y((_rotation * speed) * delta)

	if (_rotation != 0):
		speed += accel
		
	if speed > MAX_SPEED:
		speed = MAX_SPEED
		
	direction = direction.rotated(Vector3(0, 1, 0), (_rotation * speed) * delta)

	velocity = direction * MIN_SPEED
	velocity.y -= gravity

	jumping = is_on_floor() and Input.is_action_just_pressed("player_jump")

	if jumping:
		velocity.y = JUMP_VELOCITY

	animate()
	move_and_slide()
	
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
