extends CharacterBody3D

var move_force: Vector3 = Vector3.ZERO
var smoothed_forward: Vector3 = Vector3.FORWARD
@export var rotation_smooth_speed: float = 5.0

func _ready():
	floor_max_angle = deg_to_rad(0.0)  # Disable slope climbing

func _physics_process(delta: float) -> void:
	# Apply force as an impulse to velocity
	#velocity = move_force
	#velocity = move_force * delta
	var max_accel := 100.0  # Optional clamp
	var desired_velocity = move_force
	var delta_velocity = (desired_velocity - velocity)
	if delta_velocity.length() > max_accel * delta:
		delta_velocity = delta_velocity.normalized() * max_accel * delta
	velocity += delta_velocity
	move_and_slide()
	
	# Reset external force
	#move_force = Vector3.ZERO
	
	# Smooth forward direction update
	if velocity.length() > 0.1:
		var new_forward = -velocity.normalized()
		smoothed_forward = smoothed_forward.slerp(new_forward, delta * rotation_smooth_speed)
		# Update rotation to face direction
		var target_yaw = atan2(smoothed_forward.x, smoothed_forward.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, delta * rotation_smooth_speed)
	move_force = Vector3.ZERO
	#Smoothly rotate to face movement direction
	#if velocity.length() > 0.01:
		#var target_yaw = atan2(-velocity.x, -velocity.z)
		#var current_yaw = rotation.y
		#rotation.y = lerp_angle(current_yaw, target_yaw, delta * velocity.length())
