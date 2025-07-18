extends Node3D

enum obstacle_kind {ROCK, HAND, SOUL, BARREL, AMBROSIA, HAMMER, PADDLE}

@export var obstacle : obstacle_kind
@export var amount: float = 10.


func _on_area_3d_body_entered(body):
	if body.is_in_group("Boat"):
		match obstacle:
			obstacle_kind.ROCK:
				print("rock hit ", self)
				EventBus.take_damage.emit(amount)
				EventBus.play_sound.emit("Damage")
			obstacle_kind.HAND:
				print("hand hit ", self)
				EventBus.take_damage.emit(amount)
				EventBus.play_sound.emit("Damage")
			obstacle_kind.SOUL:
				print("soul hit ", self)
				EventBus.take_damage.emit(amount)
				EventBus.play_sound.emit("Damage")
			obstacle_kind.BARREL:
				print("barrel hit ", self)
				EventBus.take_damage.emit(amount)
				EventBus.play_sound.emit("Damage")
			obstacle_kind.AMBROSIA:
				print("ambrosia hit ", self)
				EventBus.make_invincible.emit()
				EventBus.play_sound.emit("Ambrosia")
			obstacle_kind.HAMMER:
				print("hammer hit ", self)
				EventBus.repair_boat.emit(amount)
				EventBus.play_sound.emit("Hammer")
			obstacle_kind.PADDLE:
				print("paddle hit ", self)
				EventBus.boost_boat.emit()
				EventBus.play_sound.emit("Paddle")
			_:
				print("missing obstacle in player detector")
		await get_tree().create_timer(.1).timeout
		if obstacle != obstacle_kind.ROCK: get_parent().call_deferred("queue_free")
