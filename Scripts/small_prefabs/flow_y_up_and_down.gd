extends Node3D


@export var flow_strength: float = 20.0
@export var stay_time: float = 3.0
@export var transition_speed: float = 20.0

var _counter: float = 0.0
var _is_up: bool = true

var _base_position_mover: Vector3
var _base_position_particles: Vector3

@onready var mover_node: Node3D = $MoverNode
@onready var particle_node: Node3D = $ParticleNode

var _target_pos_mover: Vector3
var _target_pos_particles: Vector3

#@onready var transition_timer: Timer = $TransitionTimer

func _ready():
	#transition_timer.wait_time = stay_time
	#transition_timer.one_shot = true
	#transition_timer.timeout.connect(_on_timer_timeout)
	#transition_timer.start()  # Start the first cycle)
	
	_base_position_mover = mover_node.global_position
	_base_position_particles = particle_node.global_position
	
	_target_pos_mover = _base_position_mover
	_target_pos_particles = _base_position_particles

func _physics_process(delta):
	_counter += delta

	if _counter >= stay_time:
		_counter = 0.0
		_is_up = !_is_up

		# Move one up, the other down
		var offset = Vector3(0, flow_strength, 0)
		if _is_up:
			_target_pos_mover = _base_position_mover
			_target_pos_particles = _base_position_particles - offset
		else:
			_target_pos_mover = _base_position_mover - offset
			_target_pos_particles = _base_position_particles
		
		print(delta)

		# Smooth transition
		#if is_instance_valid(mover_node):
			#print("test")
		var counter = transition_speed * _counter
		print(counter)
		#mover_node.global_position = global_position.lerp(_target_pos_mover, Engine.get_physics_frames())
		mover_node.global_position = mover_node.global_position.move_toward(_target_pos_mover, transition_speed * delta)

		#particle_node.global_position = particle_node.global_position.move_toward(_target_pos_particles, transition_speed * delta)
