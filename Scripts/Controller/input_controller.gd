extends Node

var canvas: Node2D = null
var water: StaticBody3D = null
var camera: Camera3D = null

signal click_performed(screen_pos: Vector2, world_pos: Vector3)
signal hold_performed(screen_pos: Vector2, time: float)
signal drag_performed(start: Vector2, end: Vector2)

var is_mouse_down := false
var mouse_press_time := 0.0
var press_screen_pos := Vector2.ZERO
var press_world_pos := Vector3.ZERO
var drag_screen_pos := Vector2.ZERO
var drag_world_pos := Vector3.ZERO
var drag_threshold := 10.0
var hold_threshold := 0.3

var cooldown := 0.5  # Radial wave cooldown in seconds
var cooldown_budget := 3*0.5

func water_input(camera, event, event_position, normal, shapde_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_mouse_down = true
				mouse_press_time = 0.0
				press_screen_pos = event.position
				drag_screen_pos = event.position
			else:
				is_mouse_down = false
				handle_mouse_release(event.position, event_position)
	elif event is InputEventMouseMotion and is_mouse_down:
		drag_screen_pos = event.position
		handle_mouse_down()

func _process(delta):
	if is_mouse_down:
		mouse_press_time += delta

func handle_mouse_release(release_screen_pos: Vector2, release_water_pos: Vector3):
	var time_held = mouse_press_time
	var move_distance = press_screen_pos.distance_to(release_screen_pos)
	if time_held < hold_threshold and move_distance < drag_threshold:
		print("Clicked")
		emit_signal("click_performed", release_screen_pos, release_water_pos)
	elif time_held >= hold_threshold and move_distance < drag_threshold:
		return  # Not implemented
		#emit_signal("hold_performed", release_screen_pos, time_held)
	elif move_distance >= drag_threshold:  
		return  # Not implemented
		#canvas.hide_drag_line()
		#emit_signal("drag_performed", press_screen_pos, release_screen_pos)
	
func handle_mouse_down():
	var move_distance = press_screen_pos.distance_to(drag_screen_pos)
	if move_distance >= drag_threshold:
		canvas.show_drag_line(press_screen_pos, drag_screen_pos)


		
