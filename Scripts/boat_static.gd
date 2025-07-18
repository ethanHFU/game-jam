extends RigidBody3D

@export var rotation_smooth_speed: float = 5.0
@export var auto_rotate: bool = true

func _ready():
	# Prevent tilting (only allow rotation around Y-axis)
	axis_lock_angular_x = true
	axis_lock_angular_z = true

	# Simulate water resistance
	linear_damp = 1.5
	angular_damp = 4.0

func _physics_process(delta):
	# Smoothly rotate boat to face movement direction
	if auto_rotate and linear_velocity.length() > 0.1:
		var forward_dir = -linear_velocity.normalized()
		var target_yaw = atan2(forward_dir.x, forward_dir.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, delta * rotation_smooth_speed)
