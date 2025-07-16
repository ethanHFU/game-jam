extends CharacterBody3D

var move_force: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	# Apply force as an impulse to velocity
	velocity = move_force

	# Move with collision handling
	move_and_slide()
	
	# Reset external force
	#move_force = Vector3.ZERO
	
	# Smoothly rotate to face movement direction
	if velocity.length() > 0.01:
		var target_yaw = atan2(-velocity.x, -velocity.z)
		var current_yaw = rotation.y
		rotation.y = lerp_angle(current_yaw, target_yaw, delta * velocity.length())
