extends AnimationPlayer

func _ready():
	EventBus.sink_boat.connect(_play)

func _play() -> void:
	play("sinking")
