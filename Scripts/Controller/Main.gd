extends Node

@onready var level_manager = $LevelManager
@onready var input_controller = $InputController
@onready var water_controller = $WaterEventController
@onready var canvas_controller = $CanvasLayer/Canvas
@export var radial_wave_scene: PackedScene

func _ready():
	water_controller.canvas = canvas_controller
	water_controller.radial_wave_scene = radial_wave_scene
	water_controller.level_manager = level_manager
	water_controller.boat = $Boat
	water_controller.camera = $Camera3D
	canvas_controller.camera = $Camera3D
	
	input_controller.canvas = canvas_controller
	input_controller.camera = $Camera3D
	input_controller.water = $Water_River/StaticBody3D
	
	# Connect input controller signals
	$Water_River/StaticBody3D.connect("input_event", Callable(input_controller, "water_input"))
	
	input_controller.connect("click_performed", _on_click_performed)
	input_controller.connect("click_performed", _on_click_performed)
	
	input_controller.connect("hold_performed", Callable(water_controller, "spawn_geyser"))
	input_controller.connect("drag_performed", Callable(water_controller, "spawn_directed_wave"))

func _on_click_performed(screen_pos: Vector2, world_pos: Vector3):  # Ugly way of handling callbacks with varying args
	water_controller.spawn_radial_wave(screen_pos, world_pos)
	level_manager.subtract_wave()
	
