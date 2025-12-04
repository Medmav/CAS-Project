extends CharacterBody2D
class_name PlayerController

@export var grapple : RayCast2D
@export var grapplePin : PinJoint2D # Pin joint in between rope and grappled object/surface
@export var anchorCollision : CollisionShape2D # Collision Shape of the Static body that anchors the grapple
var grappledObject
@export var grappleRange : int
var grappleRadius : float
@export var grappleStrength : int
@export var grappleDirection : Vector2
@export var grappleGravity : int
@export var fastfallGravity : int
var fastfall : bool
@export var reticalRange : int
#Change back to constant when find the right value 
@export var jumpGravity := 400
@export var fallGravity := 900
@export var walkSpeed := 100 #speed at which the character moves by default when a&d are pressed
var amountOfJumps := 1
var mousePosition : Vector2
var mouseDirection : Vector2
var collisionPoint : Vector2
var globalGrapplePoint : Vector2
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
	if Input.is_action_just_pressed("Slide"):
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
			print("jumping")
	if Input.is_action_just_released("Jump"):
		if jumpCounter < amountOfJumps:
			jumpCounter += 1
#endregion
#region Move Down Control
	if Input.is_action_pressed("Move Down"):
		fastfall = true
	if Input.is_action_just_released("Move Down"):
		fastfall = false
#endregion
#region Grapple Logic
	if grapple != null:
		if not grappled:
			grapple.target_position = grappleRange * mouseDirection
			collisionPoint = to_local(grapple.get_collision_point())
		# Input for grappling
		if Input.is_action_just_pressed("Grapple"):
			if grapple.is_colliding():
				globalGrapplePoint = to_global(collisionPoint)
				grappledObject = grapple.get_collider()
				if velocity.y > 0:
					velocity.y /= 2
		if Input.is_action_pressed("Grapple"):
			if grapple.is_colliding() && grapplePin != null:
				grapplePull()
				#grapplePin.position = collisionPoint
				#anchorCollision.position = collisionPoint
				#anchorCollision.set_deferred("disabled", false)
				grappled = true
		if Input.is_action_just_released("Grapple"):
			anchorCollision.disabled = true
			grappled = false
	if grappled:
		pass
#endregion
#endregion
	queue_redraw()
	move_and_slide()
	# End of Physics Process Loop
	
func _input(event):
	# If the mouse goes off the screen it reports the last position
	if event is InputEventMouseMotion:
		mousePosition = event.position
		
#drawing the grapple
func _draw():
	if grapple.is_colliding():
		draw_circle(collisionPoint, 5.0, Color.GREEN, true)
		if grapplePin != null && grappled:
			draw_circle(grapplePin.position, 5.0, Color.RED, true)
			
		if grappled:
			draw_line(Vector2(0,0), collisionPoint, Color.GREEN, 3.0, true)
			
	draw_circle(reticalRange * mouseDirection, 5.0, Color.YELLOW, true)
#end of func _draw()
#region getGravity() -> int
func getGravity() -> int:
	if grappled:
		return grappleGravity
	elif fastfall:
		print("falling fast")
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
	collisionPoint = to_local(globalGrapplePoint)
	grappleDirection = collisionPoint.normalized()
	velocity += grappleStrength * grappleDirection
