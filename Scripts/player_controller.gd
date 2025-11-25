extends CharacterBody2D
class_name PlayerController

#Change back to constant when find the right value 
@export var jumpGravity := 400
@export var fallGravity := 900
@export var walkSpeed := 100 #speed at which the character moves by default when a&d are pressed
var amountOfJumps := 1
@export var jumpLimit := -250
var jumpCounter := 0
var sliding := false
var jumping := false
var falling := false
var terminalVelocity := 1000
var direction : float = 0.0
var lastDirection : float = 0.0
@export var jumpStrength := 50
@export var slideFriction := 300.0
@export var slideSpeed := 250
@export var walkFriction := 500.0

#Player inputs and controls
func _physics_process(delta : float) -> void:
	countJumps()
	applyFriction(delta)
#region Applying Gravity
	if not is_on_floor() && velocity.y < terminalVelocity:
		velocity.y += getGravity() * delta
#endregion
#region Movement
#region Walk Control
	direction = Input.get_axis("Move Left", "Move Right")
	if direction:
		lastDirection = direction
	if direction && abs(velocity.x) <= walkSpeed:
		velocity.x = direction * walkSpeed
		sliding = false
#endregion
#region Slide Control
	if Input.is_action_just_pressed("Slide"):
		if is_on_floor() && abs(velocity.x) >= walkSpeed && not sliding:
				velocity.x += lastDirection * slideSpeed
				sliding = true
				print(velocity.x)
#endregion
#region Jump Control
	if Input.is_action_pressed("Jump"):
		if jumpCounter < amountOfJumps && velocity.y > jumpLimit:
			velocity.y -= jumpStrength
		if velocity.y <= jumpLimit:
			jumpCounter += 1
			
			print("jumping")
	if Input.is_action_just_released("Jump"):
		jumpCounter += 1
#endregion
#endregion
	move_and_slide()
	# End of Physics Process Loop
	
#region getGravity() -> int
func getGravity() -> int:
	if velocity.y >= 0:
		jumping = true
		return jumpGravity
	elif velocity.y < 0:
		jumping = false
		falling = true
		return fallGravity
	else:
		return 0
	# End of getGravity Function
#endregion
#region countJumps()
func countJumps():
	if is_on_floor():
		falling = false
		jumpCounter = 0
	# End of countJumps Function
#endregion
#region getFriction() -> float
func getFriction() -> float:
	if sliding:
		#print("slideFriction")
		return slideFriction
	elif not sliding:
		#print("walkFriction")
		return walkFriction
	else:
		print("No Friction")
		return 0.0
#endregion
#region applyFriction()
func applyFriction(delta):
	if is_on_floor() && velocity.x:
		velocity.x = move_toward(velocity.x, 0.0, getFriction() * delta)
		#print("applying friction")
#endregion
	
