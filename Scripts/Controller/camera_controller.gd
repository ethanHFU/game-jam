extends Camera3D

@export var boat_path: NodePath  # Assign the boat node in the inspector
@export var offset: Vector3 = Vector3(0, 350, 0)  # Camera offset (relative to boat)
@export var smooth_speed: float = 5.0  # Lerp speed

var boat: Node3D
var fixed_x: float
var fixed_y: float

func _ready():
	boat = get_node(boat_path)
	
	# Look straight down
	basis = Basis(Vector3(0, 0, -1), Vector3(-1, 0, 0), Vector3(0, 1, 0))

	# Set initial camera position centered on boat
	var start_pos = boat.global_transform.origin + offset
	global_position = start_pos
	
	# Save fixed x and y so we only follow on z
	fixed_x = global_position.x
	fixed_y = global_position.y

func _process(delta):
	var target_z = boat.global_position.z + offset.z
	var new_z = lerp(global_position.z, target_z, delta * smooth_speed)
	
	global_position = Vector3(fixed_x, fixed_y, new_z)
