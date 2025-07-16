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
	canvas_controller.camera = $Camera3D

	input_controller.canvas = canvas_controller
	
	# Connect input controller signals
	input_controller.connect("click_performed", Callable(water_controller, "spawn_radial_wave"))
	input_controller.connect("hold_performed", Callable(water_controller, "spawn_geyser"))
	input_controller.connect("drag_performed", Callable(water_controller, "spawn_directed_wave"))
	
	
