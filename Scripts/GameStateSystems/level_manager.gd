extends Node

enum level {LEVEL_1, LEVEL_2, LEVEL_3} # currently not used but might be useful
@export var levels: level

@export_group("Boat Stuff")
@export var boat_health: float = 100.
@export var is_invincible: bool = false

@export_group("Dialogue Stuff")
@export var start_dialogue_name: String = ""
@export var end_dialogue_name: String = ""

const MAX_HEALTH: float = 100.

@onready var health_bar = $"../CanvasLayer/Level_UI/MarginContainer/HealthBar"
@onready var pause_menu = %PauseMenu


func _ready():
	EventBus.repair_boat.connect(gain_health)
	EventBus.take_damage.connect(loose_health)
	EventBus.make_invincible.connect(invincibility)
	EventBus.trigger_level_end.connect(level_outro_events)
	
	preload("res://Dialog_Bilder/Textbox.tres").prepare() # prepare dialogic resource
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	#level_intro_events()


func _input(event):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		pause_menu.visible = true
		print(get_tree().paused)
		

func gain_health(amount: float) -> void:
	# update internal state
	boat_health += amount
	boat_health = min(MAX_HEALTH, boat_health)
	
	# update ui
	health_bar.value = boat_health

func loose_health(amount: float) -> void:
	if is_invincible and amount <= 100.: return # no damage when invincible, except for tornado
	
	# update internal state
	boat_health -= amount
	boat_health = max(0.0, boat_health)
	
	# update ui
	health_bar.set_value_no_signal(boat_health) 
	
	if boat_health <= 0.0:
		sink_boat()

func sink_boat() -> void:
	# start animation
	# send event to deactivate mechanics
	await get_tree().create_timer(2.).timeout # wait until anim is finished 
	# game over screen or something
	await get_tree().create_timer(1.).timeout # leave game over message on screen for a second
	EventBus.load_scene.emit("level_select") # go back to level select

func invincibility() -> void:
	is_invincible = true
	# activate some kind of visual or auditory clue for invincibility
	await get_tree().create_timer(10.).timeout # make timer node so that i-frames can easily stack
	is_invincible = false

func level_intro_events() -> void:
	# starte cutscene vor dem level in eigener szene
	# starte main theme
	EventBus.play_sound.emit("MainTheme")
	EventBus.play_sound.emit("Ruderboot")
	
	Dialogic.start(start_dialogue_name).process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.timeline_ended.connect(unpause)
	await get_tree().create_timer(1.).timeout
	get_tree().paused = true

func unpause() -> void:
	get_tree().paused = false


func level_outro_events() -> void:
	# starte event wenn steg sichtbar ist
	Dialogic.start(end_dialogue_name).process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.timeline_ended.connect(kill_player)
	await get_tree().create_timer(1.).timeout

func kill_player() -> void:
	# character stirbt
	await get_tree().create_timer(5.).timeout
	# remember that this does not work, when debug mode is enabled in sceneloader
	match levels:
		level.LEVEL_1:
			EventBus.load_scene.emit("phlegeton")
		level.LEVEL_2:
			EventBus.load_scene.emit("kokytus")
		level.LEVEL_3:
			EventBus.load_scene.emit("main_menu")
		_:
			print("[LevelManager] level not available")
