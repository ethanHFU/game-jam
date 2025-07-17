# This script controls the shader behaviour of a instanced radial wave
extends Node3D

var _clicked: bool = false
var _counter: float = 0.0

func _physics_process(delta):
	var toggle: bool = true
	if toggle == _clicked:
		_counter = lerp(_counter, 20.0, delta*.75)
		RenderingServer.global_shader_parameter_set("expand_wave", _counter)
		if _counter >= 19.0:
			_clicked = false
			_counter = 0.0

func _on_static_body_3d_input_event(camera, event, event_position, normal, shape_idx):
	if Input.is_action_just_pressed("click"):
		_clicked = true
		_counter = 0.0
		RenderingServer.global_shader_parameter_set("wave_origin", event_position)
