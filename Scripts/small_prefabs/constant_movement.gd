extends GPUParticles3D

@export var use_this_feature: bool = false
@export var speed: float = 10.0
@export var stop_point: float = -300.0

func _physics_process(delta):
	if use_this_feature and position.z >= stop_point:
		global_position += Vector3(0.0, 0.0, -delta * speed)
