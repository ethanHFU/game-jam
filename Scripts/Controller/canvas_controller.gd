extends Node2D

@onready var camera: Camera3D = get_tree().get_root().get_node("Test/Camera3D")

var wave_arcs: Array = []
var origin_markers: Array = []
var force_screen_start: Vector2
var force_screen_end: Vector2
var drag_line_start: Vector2
var drag_line_end: Vector2
var show_force := false
var show_drag := false

func _process(delta: float) -> void:
	var expired := []
	for i in range(origin_markers.size()):
		origin_markers[i]["time"] += delta
		if origin_markers[i]["time"] >= 1.0:
			expired.append(i)
	expired.reverse()
	for i in expired:
		origin_markers.remove_at(i)
	queue_redraw()

func _draw():
	# Draw wave arcs
	for arc in wave_arcs:
		draw_arc(arc.center, arc.radius, 0, TAU, 64, Color.RED)
		if arc.direction != null and arc.angle != null:
			var origin = arc.origin_3d
			var dir = arc.direction.normalized()
			dir.y = 0  # Flatten to XZ
			var forward_2d = Vector2(dir.x, dir.z)

			var screen_center = arc.center
			var radius = arc.radius
			var left = screen_center + forward_2d.rotated(arc.angle / 2.0) * radius
			var right = screen_center + forward_2d.rotated(-arc.angle / 2.0) * radius

			draw_line(screen_center, left, Color.DARK_RED, 2)
			draw_line(screen_center, right, Color.DARK_RED, 2)
	# Draw temporary origin markers
	for marker in origin_markers:
		draw_circle(marker.center, marker.radius, Color.RED)
	# Draw force line if set
	if show_force:
		draw_line(force_screen_start, force_screen_end, Color.RED, 3)
	# Draw drag line
	if show_drag:
		draw_line(drag_line_start, drag_line_end, Color.DARK_ORANGE, 3)
	
func show_wave_radius(world_pos: Vector3, radius_in_world_units: float, direction = null, opening_angle = null):
	var screen_center = camera.unproject_position(world_pos)
	var world_edge = world_pos + Vector3(radius_in_world_units, 0, 0)
	var screen_edge = camera.unproject_position(world_edge)
	var screen_radius = (screen_edge - screen_center).length()

	wave_arcs.append({
		"center": screen_center,
		"radius": screen_radius,
		"origin_3d": world_pos,
		"direction": direction,
		"angle": opening_angle,
	})
	queue_redraw()

func show_disappearing_marker(world_pos: Vector3, screen_radius := 3.0):
	var screen_center = camera.unproject_position(world_pos)
	origin_markers.append({
		"center": screen_center,
		"radius": screen_radius,
		"time": 0.0
	})
	queue_redraw()

func show_force_line_3D(world_pos_start: Vector3, world_pos_end: Vector3):
	force_screen_start = camera.unproject_position(world_pos_start)
	force_screen_end = camera.unproject_position(world_pos_end)
	show_force = true
	queue_redraw()

func show_drag_line(screen_pos_start: Vector2, screen_pos_end: Vector2):
	drag_line_start = screen_pos_start
	drag_line_end = screen_pos_end
	show_drag = true
	queue_redraw()

func hide_drag_line():
	show_drag = false
	queue_redraw()
	
