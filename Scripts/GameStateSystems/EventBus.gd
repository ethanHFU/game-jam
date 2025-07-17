extends Node


### save and load ###
signal save_to_disc
signal load_from_disc

### load scenes ###
signal load_scene(scene: String)

### audio stuff ###
signal play_sound(stream: String)

### level stuff ###
signal take_damage(amount: float)
signal repair_boat(amount: float)
signal make_invincible()
signal boost_boat()
signal trigger_level_end()
