extends Node

@export_group("Boat Stuff")
@export var boat_health: float = 100.
@export var is_invincible: bool = false

@export_group("Dialogue Stuff")
@export var dialogue_name: String = ""

const MAX_HEALTH: float = 100.

@onready var health_bar = $"../CanvasLayer/Level_UI/MarginContainer/HealthBar"


func _ready():
	EventBus.repair_boat.connect(gain_health)
	EventBus.take_damage.connect(loose_health)
	EventBus.make_invincible.connect(invincibility)


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
	pass

func level_outro_events() -> void:
	pass
