extends Node

@onready var input_controller = $InputController
@onready var water_controller = $WaterEventController
@onready var canvas_controller = $CanvasLayer/CanvasController

func _ready():
	# Pass reference to canvas controller
	water_controller.canvas = canvas_controller
	water_controller.boat = $Boat
	water_controller.camera = $Camera3D
	canvas_controller.camera = $Camera3D

	input_controller.canvas = canvas_controller

	# Connect input controller signals
	input_controller.connect("click_performed", Callable(water_controller, "handle_click"))
	input_controller.connect("hold_performed", Callable(water_controller, "handle_hold"))
	input_controller.connect("drag_performed", Callable(water_controller, "handle_drag"))
