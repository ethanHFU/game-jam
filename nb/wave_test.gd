extends Node3D

@export var ampl_curve: Curve

var _clicked: bool = false
var _counter: float = 0.0

func _physics_process(delta):
	var toggle: bool = true
	if toggle == _clicked:
		_counter = lerp(_counter, 1.0, delta)
		RenderingServer.global_shader_parameter_set("ampl_decrement", ampl_curve.sample(_counter)*1.5)
		if _counter <= 0.0:
			_clicked = false
			_counter = RenderingServer.global_shader_parameter_get("ampl_decrement")
		

func _on_static_body_3d_input_event(camera, event, event_position, normal, shape_idx):
	if Input.is_action_just_pressed("click"):
		_clicked = true
		_counter = 0.0
		RenderingServer.global_shader_parameter_set("wave_origin", event_position)
