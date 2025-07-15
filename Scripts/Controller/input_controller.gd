extends Node

var canvas: Node2D = null

signal click_performed(pos: Vector2)
signal hold_performed(pos: Vector2, time: float)
signal drag_performed(start: Vector2, end: Vector2)

var is_mouse_down := false
var mouse_press_time := 0.0
var mouse_press_pos := Vector2.ZERO
var drag_curr_pos := Vector2.ZERO
var drag_threshold := 10.0
var hold_threshold := 0.3

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_mouse_down = true
				mouse_press_time = 0.0
				mouse_press_pos = event.position
				drag_curr_pos = event.position
			else:
				is_mouse_down = false
				handle_mouse_release(event.position)
	elif event is InputEventMouseMotion and is_mouse_down:
		drag_curr_pos = event.position
		handle_mouse_down()

func _process(delta):
	if is_mouse_down:
		mouse_press_time += delta

func handle_mouse_down():
	var move_distance = mouse_press_pos.distance_to(drag_curr_pos)
	if move_distance >= drag_threshold:
		canvas.show_drag_line(mouse_press_pos, drag_curr_pos)

func handle_mouse_release(release_pos: Vector2):
	var time_held = mouse_press_time
	var move_distance = mouse_press_pos.distance_to(release_pos)
	if time_held < hold_threshold and move_distance < drag_threshold:
		emit_signal("click_performed", release_pos)
		print("Click performed")
	elif time_held >= hold_threshold and move_distance < drag_threshold:
		emit_signal("hold_performed", release_pos, time_held)
	elif move_distance >= drag_threshold:
		canvas.hide_drag_line()
		emit_signal("drag_performed", mouse_press_pos, release_pos)
		print("Drag performed")
		
