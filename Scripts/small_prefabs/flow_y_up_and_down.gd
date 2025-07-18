extends Node3D

@export var flow_strength: float = 20.0
@export var stay_time: float = 3.0
@export var transition_speed: float = 20.0
@export var phase_shift: float = 0.0  # Phase offset in seconds

var _counter: float = 0.0
var _is_up: bool = true

var _base_position_mover: Vector3
var _base_position_particles: Vector3

@onready var mover_node: Node3D = $MoverNode
@onready var particle_node: Node3D = $ParticleNode

var _target_pos_mover: Vector3
var _target_pos_particles: Vector3

func _ready():
	_base_position_mover = mover_node.global_position
	_base_position_particles = particle_node.global_position

	_target_pos_mover = _base_position_mover
	_target_pos_particles = _base_position_particles

func _physics_process(delta):
	_counter += delta

	# Apply phase-shifted logic
	var shifted_time = fmod(_counter + phase_shift, 2.0 * stay_time)
	var new_is_up = shifted_time < stay_time

	# Only update targets when direction changes
	if new_is_up != _is_up:
		_is_up = new_is_up
		var offset = Vector3(0, flow_strength, 0)

		if _is_up:
			_target_pos_mover = _base_position_mover
			_target_pos_particles = _base_position_particles - offset
		else:
			_target_pos_mover = _base_position_mover - offset
			_target_pos_particles = _base_position_particles

	# Smooth movement every frame
	if is_instance_valid(mover_node):
		mover_node.global_position = mover_node.global_position.move_toward(
			_target_pos_mover,
			transition_speed * delta
		)
		particle_node.global_position = particle_node.global_position.move_toward(
			_target_pos_particles,
			transition_speed * delta
		)
