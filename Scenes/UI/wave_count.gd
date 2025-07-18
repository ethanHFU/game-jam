extends HBoxContainer

func add_wave_icon():
	print("added image")
	var icon = TextureRect.new()
	icon.texture = preload("res://Resources/UI/UX Bilder/wave_icon.png")
	
	# Set desired size
	#icon.scale = Vector2(0.25, 0.25)
	icon.custom_minimum_size = Vector2(32, 32)
	icon.set_v_size_flags(Control.SIZE_SHRINK_BEGIN)
	icon.set_h_size_flags(Control.SIZE_SHRINK_BEGIN)
	
	
	#icon.set_anchors_preset(Control.PRESET_CENTER)
	#icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	#icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	# Prevent stretching
	#icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	add_child(icon)

func remove_wave_icon():
	if get_child_count() > 0:
		get_child(0).queue_free()  # Or remove the last, depending on your preference
