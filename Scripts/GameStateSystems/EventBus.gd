extends Node


### save and load ###
signal save_to_disc
signal load_from_disc

### load scenes ###
signal load_scene(scene: String)

### audio stuff ###
signal play_sound(stream: String)
signal stop_all_sounds

### level stuff ###
signal take_damage(amount: float)
signal repair_boat(amount: float)
signal make_invincible
signal boost_boat
signal trigger_level_end

### anim stuff ###
signal sink_boat # notify boat mesh to start its anim
