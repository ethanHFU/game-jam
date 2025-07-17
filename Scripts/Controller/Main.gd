extends Node

@onready var input_controller = $InputController
@onready var water_controller = $WaterEventController
@onready var canvas_controller = $CanvasLayer/Canvas
@export var radial_wave_scene: PackedScene


func _ready():
	water_controller.canvas = canvas_controller
	water_controller.radial_wave_scene = radial_wave_scene
	water_controller.boat = $Boat
	water_controller.camera = $Camera3D
	water_controller.water_plane_y = $Water_River.global_position.y
	canvas_controller.camera = $Camera3D
	
	input_controller.canvas = canvas_controller
	input_controller.water = $Water_River/StaticBody3D
	
	# Connect input controller signals
	$Water_River/StaticBody3D.connect("input_event", Callable(input_controller, "water_input"))
	input_controller.connect("click_performed", Callable(water_controller, "spawn_radial_wave"))
	input_controller.connect("hold_performed", Callable(water_controller, "spawn_geyser"))
	input_controller.connect("drag_performed", Callable(water_controller, "spawn_directed_wave"))
	
	
