extends Control


func _on_start_button_button_down():
	EventBus.load_scene.emit("level_select")


func _on_settings_button_button_down():
	EventBus.load_scene.emit("settings")


func _on_quit_button_button_down():
	get_tree().quit()
