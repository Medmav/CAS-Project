extends CharacterBody2D

#Change back to constant when find the right value
@export var jumpGravity := 0
@export var fallGravity := 0
@export var walkSpeed := 0 #speed at which the character moves by default when a&d are pressed
var jumpLimit := 1
var jumpCounter := 0
@export var jumpHeight := 0
@export var slideSpeed := 0

#Player inputs and controls
func _input(event: InputEvent):
	# Walk Left Control
	if event.is_action_pressed("Move Left"):
		if velocity.x < walkSpeed:
			velocity.x = -walkSpeed
			print("walking left")
	# Walk Right Control
	if event.is_action_pressed("Move Right"):
		if velocity.x < walkSpeed:
			velocity.x = walkSpeed
			print("walking right")
	# Slide Control
	if event.is_action_pressed("Slide"):
		if is_on_floor() && abs(velocity.x) >= walkSpeed:
			velocity.x += slideSpeed
			print("sliding")
	# Jump Control
	if event.is_action_pressed("Jump"):
		if jumpCounter < jumpLimit && is_on_floor():
			velocity.y = jumpHeight
			print("jumping")
#Called on consistently 60 times per second
func _physics_process(_delta):
	getGravity()
	
	
func getGravity():
	if velocity.y >= 0:
		velocity.y -= jumpGravity
	elif velocity.y < 0:
		velocity.y -= fallGravity
	
