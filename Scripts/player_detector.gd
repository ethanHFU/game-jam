extends Node3D

enum obstacle_kind {ROCK, HAND, SOUL, BARREL, AMBROSIA, HAMMER, PADDLE}

@export var obstacle : obstacle_kind
@export var amount: float = 10.



func _on_area_3d_body_entered(body):
	if body.is_in_group("Boat"):
		match obstacle_kind:
			obstacle_kind.ROCK:
				pass
			obstacle_kind.HAND:
				pass
			obstacle_kind.SOUL:
				pass
			obstacle_kind.BARREL:
				pass
			obstacle_kind.AMBROSIA:
				pass
			obstacle_kind.HAMMER:
				pass
			obstacle_kind.PADDLE:
				pass
			_:
				print("missing obstacle in player detector")
				
