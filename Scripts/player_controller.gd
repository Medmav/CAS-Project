extends CharacterBody2D
class_name PlayerController

#Change back to constant when find the right value
@export var jumpGravity := 0
@export var fallGravity := 0
@export var walkSpeed := 0 #speed at which the character moves by default when a&d are pressed
var jumpLimit := 1
var jumpCounter := 0
var sliding := false
var jumping := false
var falling := false
var terminalVelocity := 1000
var direction : float = 0.0
@export var jumpStrength := 0
@export var slideFriction := 0.0
@export var slideSpeed := 0
@export var walkFriction := 10000.0

#Player inputs and controls
func _physics_process(delta: float) -> void:
	countJumps()
	applyFriction()
#region Applying Gravity
	if not is_on_floor() && velocity.y < terminalVelocity:
		velocity.y += getGravity() * delta
#endregion
#region Movement
#region Walk Control
	direction = Input.get_axis("Move Left", "Move Right")
	if direction && velocity.x < walkSpeed:
		velocity.x = direction * walkSpeed
		sliding = false
#endregion
#region Slide Control
	if Input.is_action_just_pressed("Slide"):
		if is_on_floor() && abs(velocity.x) >= walkSpeed:
			velocity.x += slideSpeed
			sliding = true
			print("sliding")
#endregion
#region Jump Control
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor():
			jumpCounter = 0
		if jumpCounter < jumpLimit:
			velocity.y = -jumpStrength
			jumpCounter += 1
			
			print("jumping")
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
		print("slideFriction")
		return slideFriction
	elif not sliding:
		print("walkFriction")
		return walkFriction
	else:
		print("No Friction")
		return 0.0
#endregion
#region applyFriction()
func applyFriction():
	if is_on_floor:
		velocity.x = move_toward(velocity.x, 0.0, getFriction())
		#print("applying friction")
#endregion
