extends Node3D

enum obstacle_kind {ROCK, HAND, SOUL, BARREL, AMBROSIA, HAMMER, PADDLE}

@export var obstacle : obstacle_kind
@export var amount: float = 10.

func _on_area_3d_body_entered(body):
	if body.is_in_group("Boat"):
		match obstacle_kind:
			obstacle_kind.ROCK:
				EventBus.take_damage.emit(amount)
			obstacle_kind.HAND:
				EventBus.take_damage.emit(amount)
			obstacle_kind.SOUL:
				EventBus.take_damage.emit(amount)
			obstacle_kind.BARREL:
				EventBus.take_damage.emit(amount)
			obstacle_kind.AMBROSIA:
				EventBus.make_invincible.emit()
			obstacle_kind.HAMMER:
				EventBus.repair_boat.emit(amount)
			obstacle_kind.PADDLE:
				EventBus.boost_boat.emit()
			_:
				print("missing obstacle in player detector")
