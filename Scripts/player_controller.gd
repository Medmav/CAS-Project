extends CharacterBody2D
class_name PlayerController

@export var grapple : RayCast2D
var grappledObject
@export var grappleRange : int = 400
var grappleRadius : float
@export var grappleStrength : int = 15
@export var grappleDirection : Vector2
@export var grappleGravity : int
@export var grappleCatch : int = 2 #the factor falling velocity.y is divided by when the grapple attaches
var grapplePoint : Vector2
@export var fastfallGravity : int = 3000
var fastfall : bool
@export var reticalRange : int = 20
#Change back to constant when find the right value 
@export var jumpGravity := 400
@export var fallGravity := 1200
@export var walkSpeed := 100 #speed at which the character moves by default when a&d are pressed
var amountOfJumps := 1
@export var jumpLimit := -200
var jumpCounter : int = 0
var hasJumped : bool
var sliding := false
var jumping := false
var falling := false
var terminalVelocity := 1000
var mousePosition : Vector2
var mouseDirection : Vector2
var collisionPoint : Vector2
var globalGrapplePoint : Vector2
var direction : float = 0.0
var lastDirection : float = 0.0
@export var jumpStrength := 3000
@export var slideFriction := 300.0
@export var slideSpeed := 250
@export var walkFriction := 500.0
var grappled := false
	
#Player inputs and controls
func _physics_process(delta : float) -> void:
	countJumps()
	applyFriction(delta)
	setMouseDirection()
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
	if Input.is_action_pressed("Slide"):
		if is_on_floor() && abs(velocity.x) >= walkSpeed && not sliding:
				velocity.x += lastDirection * slideSpeed
				sliding = true
				print(velocity.x)
#endregion
#region Jump Control
	if Input.is_action_pressed("Jump"):
		if jumpCounter < amountOfJumps && velocity.y > jumpLimit && velocity.y <= 0:
			velocity.y -= jumpStrength * delta
		if velocity.y <= jumpLimit:
			jumpCounter += 1
			hasJumped = true
	if Input.is_action_just_released("Jump"):
		if jumpCounter < amountOfJumps && not hasJumped:
			jumpCounter += 1
		hasJumped = false
#endregion
#region Move Down Control
	if Input.is_action_pressed("Move Down"):
		fastfall = true
	if Input.is_action_just_released("Move Down"):
		fastfall = false
#endregion
#region Grapple Logic
	if grapple != null:
		grappleCheck()
		# Input for grappling
		if Input.is_action_just_pressed("Grapple"):
			grappleAttach()
		if Input.is_action_pressed("Grapple"):
			grapplePull()
		if Input.is_action_just_released("Grapple"):
			grappled = false
#endregion
#endregion
	print(grappled)
	queue_redraw()
	move_and_slide()
	# End of Physics Process Loop
		
#drawing the grapple
func _draw():
	if grapple.is_colliding():
		draw_circle(collisionPoint, 5.0, Color.GREEN, true)
	if grappled:
		draw_circle(collisionPoint, 5.0, Color.RED, true)
	if grappled:
		draw_line(Vector2(0,0), collisionPoint, Color.GREEN, 3.0, true)
	draw_circle(reticalRange * mouseDirection, 5.0, Color.YELLOW, true)
	draw_line(Vector2(0,0), velocity * 0.1, Color.RED, 3.0)
#end of func _draw()
#region getGravity() -> int
func getGravity() -> int:
	if grappled:
		return grappleGravity
	elif fastfall:
		return fastfallGravity
	elif velocity.y <= 0:
		jumping = true
		return jumpGravity
	elif velocity.y > 0:
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
	if is_on_floor() || abs(velocity.x) <= walkSpeed && velocity.x:
		velocity.x = move_toward(velocity.x, 0.0, getFriction() * delta)
		#print("applying friction")
#endregion
#region setMouseDirection()
func setMouseDirection():
	mousePosition = get_local_mouse_position()
	mouseDirection = mousePosition.normalized()
#endregion
func grapplePull():
	if grappled:
		collisionPoint = to_local(globalGrapplePoint)
		grappleDirection = collisionPoint.normalized()
		velocity += grappleStrength * grappleDirection
		print("pulling")
	
func grappleAttach():
	if grapple.is_colliding():
		collisionPoint = to_local(grapple.get_collision_point())
		globalGrapplePoint = grapple.get_collision_point()
		grappledObject = grapple.get_collider()
		grappled = true
		if velocity.y > 0 && globalGrapplePoint.y < global_position.y:
			velocity.y /= grappleCatch
			
func grappleCheck(): #checks if the player can grapple
	if not grappled:
		grapple.target_position = grappleRange * mouseDirection
		if grapple.is_colliding():
			collisionPoint = to_local(grapple.get_collision_point())
		else:
			collisionPoint = Vector2(0,0)
