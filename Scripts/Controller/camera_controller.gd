extends Camera3D

@export var boat_path: NodePath  # Drag the boat node into the inspector
@export var offset: Vector3 = Vector3(0, 350, 0)  # Relative offset from boat
@export var smooth_speed: float = 5.0  # For interpolation

var boat: Node3D

func _ready():
	boat = get_node(boat_path)
	basis = Basis(Vector3(0, 0, -1), Vector3(-1, 0, 0), Vector3(0, 1, 0))
func _process(delta):
	var target_pos = boat.global_transform.origin + offset
	global_transform.origin = global_transform.origin.lerp(target_pos, delta * smooth_speed)
