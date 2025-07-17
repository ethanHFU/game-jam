extends Area3D

func _on_body_entered(body):
	if body.is_in_group("Boat"):
		# level manager will receive this event 
		EventBus.trigger_level_end.emit()
