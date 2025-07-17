extends Node

@export var audiostreams: Dictionary

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _ready():
	EventBus.play_sound.connect(play_sound)
	print("audio manager is ready")

func play_sound(stream: String) -> void:
	get_node(audiostreams[stream]).play()
