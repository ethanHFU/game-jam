extends Control


func _on_acheron_button_down():
	EventBus.load_scene.emit("acheron")


func _on_phlegeton_button_down():
	EventBus.load_scene.emit("phlegeton")


func _on_kokytus_button_down():
	EventBus.load_scene.emit("kokytus")


func _on_return_button_button_down():
	EventBus.load_scene.emit("main_menu")
