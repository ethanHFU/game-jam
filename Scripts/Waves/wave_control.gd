extends Node3D

@onready var camera: Camera3D = $Camera3D  # Adjust path to your actual camera
@onready var water_obj: CollisionShape3D = $StaticBody3D/WaterSurface
@onready var boat: Node3D = $Boat
@onready var canvas: Node2D = $CanvasLayer/Canvas



var wave_pos: Vector3
var wave_radius_max = 10.0
var wave_radius_curr = 0.0
var wave_speed = 5.0
var waves_active = false
var boat_rotated = false

var boat_rotating := false
var rotation_timer := 0.0
var rotation_duration := 3.0  # seconds

var boat_initial_rotation: Basis
var boat_target_rotation: Basis

var marker_scene = preload("res://Scenes/Debug/ClickMarker.tscn")

func _process(delta: float) -> void:
	if not waves_active:
		return

	wave_radius_curr += wave_speed * delta
	canvas.show_circle_at(wave_pos, wave_radius_curr)
	if wave_radius_curr >= wave_radius_max:
		waves_active = false
		boat_rotating = false
		return

	var boat_pos = boat.global_position
	var wave_to_boat = boat_pos - wave_pos
	var distance = wave_to_boat.length()

	if distance > wave_radius_curr:
		return  # Boat not reached yet

	# Rotate the boat once, when hit
	if not boat_rotated:
		var dir = wave_to_boat.normalized()
		dir.y = 0
		var target_basis = Basis().looking_at(dir, Vector3.UP)

		# Store initial and target rotations
		boat_initial_rotation = boat.global_transform.basis
		boat_target_rotation = target_basis.scaled(boat.scale)  # Preserve scale

		rotation_timer = 0.0
		boat_rotating = true
		boat_rotated = true

	# Move boat outward smoothly
	var remaining = wave_radius_max - distance
	if remaining > 0.01:
		var move_step = min(delta * wave_speed, remaining)
		boat.translate_object_local(Vector3(0, 0, -move_step))
		
	if boat_rotating:
		rotation_timer += delta
		var t = clamp(rotation_timer / rotation_duration, 0.0, 1.0)

		# Interpolate using slerp (quaternion-based)
		var current_quat = boat_initial_rotation.orthonormalized().get_rotation_quaternion()
		var target_quat = boat_target_rotation.orthonormalized().get_rotation_quaternion()
		var interpolated_quat = current_quat.slerp(target_quat, t)

		boat.global_transform.basis = Basis(interpolated_quat)

		if t >= 1.0:
			boat_rotating = false  # Done rotating
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var water_surface_y = water_obj.global_position.y + water_obj.shape.size.y / 2.0
		wave_pos = get_mouse_click_position_on_plane_y(water_surface_y, event.position)
		wave_radius_curr = 0.0
		waves_active = true
		boat_rotated = false
		
		#var wave_to_boat = boat.global_position - wave_pos
		#var wave_dir = wave_to_boat.normalized()
		#var distance = wave_radius_max - wave_to_boat.length()
		#var new_pos = boat.global_position + wave_dir * distance
		#boat.global_position = new_pos
		#
		#var new_basis = Basis().looking_at(wave_dir, Vector3.UP)
		#boat.basis = new_basis
		

		# Debugging
		spawn_marker(wave_pos)
		
func get_mouse_click_position_on_plane_y(y_value: float, mouse_pos: Vector2) -> Vector3:
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)

	# Avoid division by zero (e.g. ray parallel to plane)
	if abs(ray_dir.y) < 0.001:
		return Vector3.ZERO  # or handle appropriately

	var distance = (y_value - ray_origin.y) / ray_dir.y
	return ray_origin + ray_dir * distance
	
func spawn_marker(position: Vector3):
	var marker = marker_scene.instantiate()
	marker.global_transform.origin = position
	add_child(marker)
