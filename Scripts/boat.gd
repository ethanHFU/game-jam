extends CharacterBody3D

var move_force: Vector3 = Vector3.ZERO
var smoothed_forward: Vector3 = -Vector3.FORWARD  # Negate so the boat starts with proper orientation
@export var rotation_smooth_speed: float = 5.0

var visual_appearance: Node3D = null

func _ready():
	floor_max_angle = deg_to_rad(0.0)  # Disable slope climbing
	visual_appearance = $VisualAppearance
	visual_appearance.set_as_top_level(true)
	visual_appearance.global_transform = global_transform  # Full sync to avoid initial offset
	
func _physics_process(delta: float) -> void:
	velocity = move_force
	move_and_slide()
	
	# Smooth forward direction update
	if velocity.length() > 0.1:
		var new_forward = -velocity.normalized()
		smoothed_forward = smoothed_forward.slerp(new_forward, delta * rotation_smooth_speed)
		# Update rotation to face direction
		var target_yaw = atan2(smoothed_forward.x, smoothed_forward.z)
		if visual_appearance.is_set_as_top_level():
			var current_rotation = visual_appearance.rotation
			current_rotation.y = lerp_angle(current_rotation.y, target_yaw, delta * rotation_smooth_speed)
			visual_appearance.rotation = current_rotation
		else:
			rotation.y = lerp_angle(rotation.y, target_yaw, delta * rotation_smooth_speed)

func _process(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	var lerp_interval = move_force/fps
	var lerp_position = global_transform.origin + lerp_interval
	if fps > 60:
		visual_appearance.set_as_top_level(true)
		visual_appearance.global_transform.origin = visual_appearance.global_transform.origin.lerp(lerp_position, 20*delta)
	else:
		visual_appearance.global_transform = global_transform
		visual_appearance.set_as_top_level(false)
