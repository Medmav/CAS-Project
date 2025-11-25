extends Camera2D

@export var sprite : Sprite2D
@export var player_controller : PlayerController

func _process(delta: float) -> void:
	position = sprite.position
