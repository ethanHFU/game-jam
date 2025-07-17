extends Node3D

@export var flow_strength: float = .5
@export var phase: float = 0.0

var _counter: float = 0.0

func _physics_process(delta):
	_counter += delta
	global_position += Vector3(sin(_counter + phase)*flow_strength, 0.0, 0.0)
