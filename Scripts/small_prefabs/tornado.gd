extends Area3D


func _on_body_entered(body):
	if body.is_in_group("Boat"):
		EventBus.take_damage.emit(200.0) # instant kill
