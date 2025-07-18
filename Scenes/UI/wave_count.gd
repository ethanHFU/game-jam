extends HBoxContainer

var initialized := false

func add_wave_icon():
	var icon = TextureRect.new()
	icon.texture = preload("res://Resources/UI/UX Bilder/wave_white.png")
	icon.set_expand_mode(TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL)
	icon.set_stretch_mode(TextureRect.STRETCH_SCALE)
	icon.set_custom_minimum_size(Vector2(32, 32))
	add_child(icon)

func init(wave_budget: float):
	if initialized: 
		return
	for i in range(wave_budget):
		add_wave_icon()
	initialized = true
	
func remove_wave_icon():
	if get_child_count() > 0:
		get_child(0).queue_free()  # Or remove the last, depending on your preference
