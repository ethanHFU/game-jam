extends Node3D

@onready var camera: Camera3D = $Camera3D  # Adjust path to your actual camera
@onready var water_obj: CollisionShape3D = $StaticBody3D/WaterSurface
@onready var boat: Node3D = $Boat
@onready var canvas: Node2D = $CanvasLayer/Canvas

# Controls
var is_mouse_down := false
var mouse_press_time := 0.0
var mouse_press_pos := Vector2.ZERO
var drag_threshold := 10.0  # pixels
var hold_threshold := 0.3   # seconds

# Wave/Boat logic
const Wave = preload("res://Scripts/Waves/RadialWave.gd")
var active_waves: Array[Wave] = []
var boat_initial_rotation: Basis
var boat_target_rotation: Basis
var wave_radius_max = 10.0
var wave_speed = 5.0

# Debugging
var marker_scene = preload("res://Scenes/Debug/ClickMarker.tscn")

func _process(delta: float) -> void:
	if is_mouse_down:
		mouse_press_time += delta
	canvas.circles.clear()  # Debugging - clear circles
	for wave in active_waves:
		if not wave.active:
			print("Not active")
			return
		wave.radius += wave.speed * delta
		canvas.show_circle_at(wave.origin, wave.radius)  # Debugging
		if wave.radius >= wave.max_radius:
			wave.active = false
			active_waves.erase(wave)

		var boat_pos = boat.global_position
		var wave_to_boat = boat_pos - wave.origin
		var distance = wave_to_boat.length()

		if distance > wave.radius:
			return  # Boat not reached yet
			
		# Rotate the boat once, when hit
		if not wave.boat_rotated:
			var dir = wave_to_boat.normalized()
			dir.y = 0
			var target_basis = Basis().looking_at(dir, Vector3.UP)
	
			# Store initial and target rotations
			boat_initial_rotation = boat.global_transform.basis
			boat_target_rotation = target_basis
			
			wave.boat_rotated = true
			wave.rotating = true
		
		# Move boat outward smoothly
		var remaining = wave.max_radius - distance
		if remaining > 0.01:
			var move_step = min(delta * wave.speed, remaining)
			boat.translate_object_local(Vector3(0, 0, -move_step))
			
		if wave.rotating:
			wave.rotation_timer += delta
			var t = clamp(wave.rotation_timer / wave.rotation_duration, 0.0, 1.0)
	
			# Interpolate
			var current_quat = boat_initial_rotation.orthonormalized().get_rotation_quaternion()
			var target_quat = boat_target_rotation.orthonormalized().get_rotation_quaternion()
			var interpolated_quat = current_quat.slerp(target_quat, t)
	
			boat.global_transform.basis = Basis(interpolated_quat)
	
			if t >= 1.0:
				wave.rotating = false

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_mouse_down = true
				mouse_press_time = 0.0
				mouse_press_pos = event.position
			else:
				is_mouse_down = false
				handle_mouse_release(event.position)

func handle_mouse_release(release_pos: Vector2):
	var time_held = mouse_press_time
	var move_distance = mouse_press_pos.distance_to(release_pos)

	if time_held < hold_threshold and move_distance < drag_threshold:
		print("Fast click")
	elif time_held >= hold_threshold and move_distance < drag_threshold:
		print("Hold")
	elif move_distance >= drag_threshold:
		print("Drag")

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
