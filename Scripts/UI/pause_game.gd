extends Control


func _on_button_button_down():
	self.visible = false
	get_tree().paused = false


func _on_quit_button_down():
	self.visible = false
	get_tree().paused = false
	EventBus.load_scene.emit("level_select")
