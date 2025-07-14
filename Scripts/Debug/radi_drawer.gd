extends Node2D

var circle_center: Vector2
var radius: float = 0.0
var visible_circle := false
@onready var camera: Camera3D = get_tree().get_root().get_node("Test/Camera3D")

func _draw():
	if visible_circle:
		var segments = 64  # Adjust for smoothness
		draw_arc(circle_center, radius, 0, TAU, segments, Color.RED)

# TODO: Maybe define radius in screen space to avoid this computation.
func show_circle_at(world_position: Vector3, radius_in_world_units: float):
	if camera == null:
		push_warning("Camera not assigned to CircleDrawer.")
		return

	# Convert world position (center) to screen position
	circle_center = camera.unproject_position(world_position)

	# Convert a point radius units away in world space (e.g., +X)
	var world_edge = world_position + Vector3(radius_in_world_units, 0, 0)
	var screen_edge = camera.unproject_position(world_edge)

	# Compute screen-space radius
	radius = (screen_edge - circle_center).length()

	visible_circle = true
	queue_redraw()  # triggers _draw()

func hide_circle():
	visible_circle = false
	queue_redraw()
