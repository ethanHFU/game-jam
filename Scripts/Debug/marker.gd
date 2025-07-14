extends Node3D

func _ready():
	await get_tree().create_timer(1.0).timeout  # Wait 1 second
	queue_free()  # Destroy the marker
