extends VehicleBody3D

func _physics_process(delta):
	steering = Input.get_axis("player_right", "player_left") * 0.4
	engine_force = Input.get_axis("player_down", "player_up") * 200
