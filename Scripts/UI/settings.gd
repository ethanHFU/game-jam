extends Control


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
	AudioServer.set_bus_mute(1, value < .05)


func _on_effect_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
	AudioServer.set_bus_mute(2, value < .05)


func _on_return_button_button_down():
	EventBus.load_scene.emit("main_menu")
