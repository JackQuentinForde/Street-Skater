extends RigidBody3D

const ACCEL = 0.5
const AIR_ACCEL = 0.25
const MAX_SPEED = 10.0
const RIDE_SPEED = 10.0
const JUMP_VELOCITY = 5.0

var direction = 0.0
var zRotation = 0.0
var speed = 0.0
var accel = 0.0
var jumping = false

#variables that are set in the ready function 
var defaultRotation
var animationPlayer

func _ready():
	defaultRotation = $Skateboard.rotation
	animationPlayer = get_node("Skateboard/AnimationPlayer")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
#	if not self.is_on_floor():
#		accel = AIR_ACCEL
#	else:
#		jumping = false
#		accel = ACCEL

	if Input.is_action_just_pressed("player_jump") and self.is_on_floor():
		jumping = true
#		self.velocity.y = JUMP_VELOCITY

	direction = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	zRotation = Input.get_action_strength("player_up") - Input.get_action_strength("player_down")

	move(delta)
	animate()
	
func move(delta):
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
		
	if jumping:
		#$Skateboard.rotate_y(-(direction * 5.0) * delta)
		$Skateboard.rotate_z(-(zRotation * 10.0) * delta)
	else:
		$Skateboard.rotation = defaultRotation
	
#	self.velocity.x = RIDE_SPEED
#	self.velocity.z = speed
	
func animate():
	if jumping:
		if (animationPlayer.get_assigned_animation() != "Ollie" or 
				animationPlayer.get_current_animation_position() != animationPlayer.get_current_animation_length()):
				animationPlayer.play("Ollie")
	else:
		if animationPlayer.get_assigned_animation() == "Ollie":
			animationPlayer.set_assigned_animation("TurnRight")
		if direction > 0:
			if (animationPlayer.get_assigned_animation() != "TurnRight" or 
				animationPlayer.get_current_animation_position() != animationPlayer.get_current_animation_length()):
				animationPlayer.play("TurnRight")
		elif direction < 0:
			if (animationPlayer.get_assigned_animation() != "TurnLeft" or 
				animationPlayer.get_current_animation_position() != animationPlayer.get_current_animation_length()):
				animationPlayer.play("TurnLeft")
		elif animationPlayer.get_assigned_animation() != "Ollie":
			if animationPlayer.get_current_animation_position() != 0:
				animationPlayer.play_backwards(animationPlayer.get_assigned_animation())
