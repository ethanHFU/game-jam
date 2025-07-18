extends Node

# Assigned by Main.gd
var camera: Camera3D = null
var boat: Node3D = null
var canvas: Node = null 
var water_plane_y: float
var radial_wave_scene: PackedScene = null

# All of these factors are NOT invariant to scene size. Must be adjusted
var waves = []
var max_active_waves = 5
var wave_radius_max = 100.0
var wave_speed = 60.0
# Set wave_force_fac such that wave forces are small enough to push boat along wave perimeter,
# but not cause large jumps causing choppy look as the boat reenters the expanding wave radius.
var wave_force_fac = 100.0  
var wave_width = 10.0  # Tolerance for collision detection
var force = Vector3.ZERO 

# Directed waves config
var drag_multiplier = 10.0
var force_mag_cap = 50.0
var opening_angle = 30.0
var angle_margin = 0.1

var startup_force_multiplier := 0.0
var startup_ramp_duration: float = 5.0  # seconds
var force_bool = 1.0

func _ready():
	EventBus.trigger_level_end.connect(func():force_bool = 0.0)

func _physics_process(delta):
	canvas.wave_arcs.clear()
	
	if startup_force_multiplier < 1.0:
		startup_force_multiplier += delta / startup_ramp_duration
		startup_force_multiplier = clamp(startup_force_multiplier, 0.0, 1.0)
	
	var t = startup_force_multiplier
	var eased = t * t * (3.0 - 2.0 * t)  # Smoothstep easing

	var river_force = Vector3(0.0, 0.0, -115.0) * eased
	force = river_force

	for wave in waves:
		var wave_force = process_wave(wave, delta)
		force += wave_force
		force *= force_bool
	canvas.show_force_line(boat.global_position, boat.global_position + force)

	boat.move_force = force

func process_wave(wave, delta) -> Vector3:
	wave.radius += wave.speed * delta

	if wave is not DirectedWave:  #TODO: Remove this check and use inheritance or something
		if wave.visual_instance:
			var mesh = wave.visual_instance.get_node("Plane")
			if mesh and mesh.material_override:
				mesh.set_instance_shader_parameter("expand_wave", wave.radius/wave.vi_scale_fac)

	if wave.active:
		if wave is DirectedWave:
			canvas.show_wave_radius(wave.origin, wave.radius, wave.force, wave.opening_angle)
		else:
			canvas.show_wave_radius(wave.origin, wave.radius)

	var wave_to_boat = boat.global_position - wave.origin
	var distance = wave_to_boat.length()
	if distance > wave.radius + wave_width:
		return Vector3.ZERO
	
	if wave.radius >= 2*wave.radius_max:  #TODO: Replace with better logic. Only here to keep animation alive but stop collision
		if wave is not DirectedWave:  #TODO: Remove this check and use inheritance or something
			if wave.visual_instance:
				wave.visual_instance.queue_free()  # Delete radial wave instance
		waves.erase(wave)
		return Vector3.ZERO

	if wave.radius >= wave.radius_max:
		wave.active = false 
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
	wave_force.y = 0;
	return wave_force if wave_force.length() >= 0.01 else Vector3.ZERO

func spawn_radial_wave(screen_pos: Vector2, world_pos: Vector3):
	var timer := Timer.new()
	add_child(timer)
	canvas.show_disappearing_marker(screen_pos)
	var visual_instance = radial_wave_scene.instantiate()
	var plane_mesh_size = visual_instance.get_node("Plane").mesh.size
	var scale_factor = wave_radius_max / (plane_mesh_size.x / 2.0)
	visual_instance.scale = Vector3(scale_factor, 1.0, scale_factor)
	self.add_child(visual_instance)
	EventBus.play_sound.emit("BigWave")
	waves.append(RadialWave.new(world_pos, wave_radius_max, wave_speed, visual_instance, scale_factor))
	
func spawn_directed_wave(world_start_pos: Vector3, world_end_pos: Vector3):
	var drag_vector = world_start_pos - world_end_pos
	drag_vector.y = 0  # Flatten to XZ if needed
	var drag_length = drag_vector.length()
	if drag_length < 0.1:
		return  # Ignore too small drags
	var force_dir = drag_vector.normalized()
	var force_magnitude = clamp(drag_length * drag_multiplier, 0.0, force_mag_cap)  # Adjust scale and cap
	var force_vec = force_dir * force_magnitude
	var opening_radians = deg_to_rad(opening_angle)
	waves.append(DirectedWave.new(world_start_pos, wave_radius_max, wave_speed, force_vec, opening_radians))
	
func spawn_geyser(pos: Vector2, time: float):
	print("Geyser")


class RadialWave:
	var origin: Vector3
	var radius := 0.0
	var radius_max: float
	var speed: float
	var has_impacted := false
	var active := true
	var visual_instance: Node3D
	var vi_scale_fac: float
	func _init(_origin: Vector3, _radius_max: float, _speed: float, _visual_instance: Node3D, _vi_scale_fac: float):
		origin = _origin
		radius_max = _radius_max
		speed = _speed
		visual_instance = _visual_instance
		visual_instance.global_position = origin
		vi_scale_fac = _vi_scale_fac

class DirectedWave:
	var origin: Vector3
	var radius := 0.0
	var radius_max: float
	var speed: float
	var force: Vector3
	var active := true
	var opening_angle: float
	var has_impacted := false
	var visual_instance: Node3D
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
