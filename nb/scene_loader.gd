extends Node

@export var scenes: Dictionary
@export var loading_screen: PackedScene

@export var debug_mode: bool = false # script is deactivated if true

var _load_next_scene: bool = false
var _next_scene: String = ""
var _loading_screen: Control


func _ready() -> void:
	if not debug_mode:
		# very first steps the game makes when it gets started
		EventBus.load_scene.connect(load_scene) # connect to scene loading signal
		EventBus.load_scene.emit("main_menu") # load main menu
		_loading_screen = loading_screen.instantiate() # hold loading screen in this variable


func _process(delta):
	### scene loading ----------------------------------------------------------
	if _load_next_scene:
		self.add_child(_loading_screen)
		var progress = []
		ResourceLoader.load_threaded_get_status(scenes[_next_scene], progress)
		print("trying to load \"", _next_scene, "\", Progress: " , progress[0])
		if progress[0] >= .99:
			_load_next_scene = false
			var packed_scene = ResourceLoader.load_threaded_get(scenes[_next_scene])
			get_tree().change_scene_to_packed(packed_scene)
			remove_child(_loading_screen)
	### ------------------------------------------------------------------------
	

func load_scene(scene: String) -> void:
	ResourceLoader.load_threaded_request(scenes[scene])
	_next_scene = scene
	_load_next_scene = true 
	# rest of code is in process
