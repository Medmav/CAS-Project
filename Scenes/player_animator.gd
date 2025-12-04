extends Node

@export var player_controller : PlayerController
@export var animation_player : AnimationPlayer
@export var sprite : Sprite2D

func _process(delta: float) -> void:
	if player_controller.direction == 1:
		sprite.flip_h = false
	elif player_controller.direction == -1:
		sprite.flip_h = true
		
	if player_controller.velocity.x:
		animation_player.play("walk")
	else:
		animation_player.play("idle")
		
	if player_controller.sliding:
		animation_player.play("slide")
