extends Node3D

@export var speed: float = 20.

var _move_towards_boat: bool = false
var _boat: Node3D

func _physics_process(delta):
	if _move_towards_boat:
		var boat_vector: Vector3 = _boat.global_position - self.global_position
		boat_vector = boat_vector.normalized()
		self.global_position += boat_vector * delta * speed
		look_at(_boat.global_position, Vector3.UP)
		

func _on_area_3d_body_entered(body):
	if body.is_in_group("Boat"):
		_boat = body
		_move_towards_boat = true


func _on_area_3d_body_exited(body):
	if body.is_in_group("Boat"):
		_move_towards_boat = false
		_boat = null
