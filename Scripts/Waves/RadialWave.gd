class_name RadialWave
extends RefCounted

var origin: Vector3
var radius := 0.0
var max_radius: float
var speed: float
var active := true
var boat_rotated := false
var boat_pushed := false
var boat_target_distance := 0.0
var boat_initial_rotation: Basis
var boat_target_rotation: Basis
var rotation_timer := 0.0
var rotation_duration := 0.5
var rotating := false

func _init(_origin: Vector3, _max_radius: float, _speed: float):
	origin = _origin
	max_radius = _max_radius
	speed = _speed
