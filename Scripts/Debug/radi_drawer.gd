extends Node2D

var circle_center: Vector2
var radius: float = 0.0
var visible_circle := false
var circles: Array = []
@onready var camera: Camera3D = get_tree().get_root().get_node("Test/Camera3D")

func _draw():
	for circle in circles:
		draw_arc(circle.center, circle.radius, 0, TAU, 64, Color.RED)

# TODO: Maybe define radius in screen space to avoid this computation.
func show_circle_at(world_position: Vector3, radius_in_world_units: float):
	if camera == null:
		push_warning("Camera not assigned to CircleDrawer.")
		return

	var screen_center = camera.unproject_position(world_position)
	var world_edge = world_position + Vector3(radius_in_world_units, 0, 0)
	var screen_edge = camera.unproject_position(world_edge)
	var screen_radius = (screen_edge - screen_center).length()

	circles.append({
		"center": screen_center,
		"radius": screen_radius
	})

	queue_redraw()

func hide_circle():
	visible_circle = false
	queue_redraw()
