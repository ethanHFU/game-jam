extends Node

# Assigned by Main.gd
var camera: Camera3D = null
var water_obj: CollisionShape3D = null
var boat: Node3D = null
var canvas: Node = null 

var waves = []
var wave_radius_max = 10.0
var wave_speed = 5.0
var wave_force_fac = 20.0
var wave_width = 0.5
var turn_speed = 1.0
var force = Vector3(0.0, 0.0, -1.0)  # Contains river force

# Directed waves config
var drag_multiplier = 10.0
var force_mag_cap = 50.0
var opening_angle = 30.0
var angle_margin = 0.1

func _process(delta):
	canvas.wave_arcs.clear()
	force = Vector3(0.0, 0.0, -1.0)
	
	var wave_force
	for wave in waves:
		wave_force = process_wave(wave, delta)
		force += wave_force
		
	canvas.show_force_line_3D(boat.global_position, boat.global_position + force)

	# Gradually move and rotate boat
	boat.global_position += force * delta
	var current_yaw = boat.rotation.y
	var target_yaw = atan2(-force.x, -force.z)
	boat.rotation.y = lerp_angle(current_yaw, target_yaw, turn_speed * force.length() * delta)

func process_wave(wave, delta) -> Vector3:
	wave.radius += wave.speed * delta

	if wave is DirectedWave:
		canvas.show_wave_radius(wave.origin, wave.radius, wave.force, wave.opening_angle)
	else:
		canvas.show_wave_radius(wave.origin, wave.radius)

	if wave.radius >= wave.radius_max:
		waves.erase(wave)
		return Vector3.ZERO

	var wave_to_boat = boat.global_position - wave.origin
	var distance = wave_to_boat.length()
	if distance > wave.radius + wave_width:
		return Vector3.ZERO

	var angle_falloff = 1.0
	if wave is DirectedWave:
		var to_boat_dir = wave_to_boat.normalized()
		var wave_dir = wave.force.normalized()
		var angle = to_boat_dir.angle_to(wave_dir)
		var max_angle = wave.opening_angle / 2.0
		if angle > max_angle + angle_margin:
			return Vector3.ZERO
		angle_falloff = clamp(1.0 - (angle / max_angle), 0.0, 1.0)

	var wave_force = wave_to_boat.normalized() * wave_force_fac * (1 - wave.radius / wave.radius_max) * angle_falloff
	return wave_force if wave_force.length() >= 0.01 else Vector3.ZERO


func handle_click(pos: Vector2):
	var y = water_obj.global_position.y + water_obj.shape.size.y / 2.0
	var world_pos = get_mouse_click_position_on_plane_y(y, pos)
	canvas.show_disappearing_marker(world_pos)
	waves.append(RadialWave.new(world_pos, wave_radius_max, wave_speed))

func handle_hold(pos: Vector2, time: float):
	print("Geyser")

func handle_drag(start: Vector2, end: Vector2):
	var y = water_obj.global_position.y + water_obj.shape.size.y / 2.0
	var start_pos = get_mouse_click_position_on_plane_y(y, start)
	var end_pos = get_mouse_click_position_on_plane_y(y, end)
	var drag_vector = start_pos - end_pos
	drag_vector.y = 0  # Flatten to XZ if needed
	var drag_length = drag_vector.length()
	if drag_length < 0.1:
		return  # Ignore too small drags
	var force_dir = drag_vector.normalized()
	var force_magnitude = clamp(drag_length * drag_multiplier, 0.0, force_mag_cap)  # Adjust scale and cap
	var force_vec = force_dir * force_magnitude
	var opening_radians = deg_to_rad(opening_angle)
	waves.append(DirectedWave.new(start_pos, wave_radius_max, wave_speed, force_vec, opening_radians))

func get_mouse_click_position_on_plane_y(y_value: float, mouse_pos: Vector2) -> Vector3:
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	if abs(ray_dir.y) < 0.001:
		return Vector3.ZERO
	var distance = (y_value - ray_origin.y) / ray_dir.y
	return ray_origin + ray_dir * distance

class RadialWave:
	var origin: Vector3
	var radius := 0.0
	var radius_max: float
	var speed: float
	func _init(_origin: Vector3, _radius_max: float, _speed: float):
		origin = _origin
		radius_max = _radius_max
		speed = _speed

class DirectedWave:
	var origin: Vector3
	var radius := 0.0
	var radius_max: float
	var speed: float
	var force: Vector3
	var opening_angle: float
	func _init(_origin: Vector3, _radius_max: float, _speed: float, _force: Vector3, _opening_angle: float):
		origin = _origin
		radius_max = _radius_max
		speed = _speed
		force = _force
		opening_angle = _opening_angle

class Geyser:
	var origin: Vector3
	var intensity: float
	var speed: float
	func _init(_origin: Vector3, _intensity: float, _speed: float):
		origin = _origin
		intensity = _intensity
		speed = _speed
