extends CharacterBody3D

signal debug_info

# References
@onready var head := $Head
@onready var cam := $Head/Camera3D
@onready var hitbox := $CollisionShape3D
@onready var body := $MeshInstance3D
@onready var roofRaycast = $RoofRaycast

@export_category("States")
@export var isStanding := false
@export var isWalking := false
@export var isSprinting := false
@export var isJumping := false
@export var isCrouching := false
@export var isSliding := false

@export_category("Camera")
@export var sensitivity := 1.0
@export var fov := 75.0
@export var fovChange := 1.5
var lowerCameraClamp = -90
var higherCameraClamp = 90
var mouseMovement := Vector2.ZERO

@export_category("Walking")
@export var speed : float
@export var acceleration := 15.0
@export var deceleration := 8.5
const SPEEDS := {
	"walk": 5.0,
	"sprint": 8.0,
	"crouch": 3.0,
	"slide": 12.0
}

@export_category("Jumping")
const gravity := 9.8 # m/s^2
@export var gravityMult := 1.0
@export var jumpVelocity := 4.5
@export var airControl := 2.0
@export var coyoteTimeDur := 0.1
var coyoteTime := 0.0
var wasOnFloor := false

@export_category("Miscellaneous")
var crouchReleaseTimer := 0.0
var fps : float
var thirdPerson

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	velocity = Vector3.ZERO

func _process(_delta : float):
	fps = Engine.get_frames_per_second()

func _physics_process(delta: float):
	handle_movement(delta)
	handle_jumping(delta)
	handle_state(delta)
	handle_state_behavior()
	handle_fov(delta)
	
	move_and_slide()
	
	emit_debug()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			handle_mouselook(event)
			mouseMovement = event.relative

func apply_over_time(starting_value, end_value, increment_value, mode: String = "add"):
	if (mode == "add"):
		if (starting_value < end_value):
			starting_value += increment_value
		else:
			starting_value = end_value
	elif (mode == "subtract"):
		if (starting_value > end_value):
			starting_value -= increment_value
		else:
			starting_value = end_value
	elif (mode == "multiply"):
		if (starting_value < end_value):
			starting_value *= increment_value
		else:
			starting_value = end_value
	elif (mode == "divide"):
		if (starting_value > end_value):
			starting_value /= increment_value
		else:
			starting_value = end_value
	
	return starting_value

func handle_state(delta):
	isSprinting = Input.is_action_pressed("sprint")
	
	if Input.is_action_pressed("crouch"):
		isCrouching = true
	else:
		if not roofRaycast.is_colliding():
			crouchReleaseTimer += delta
			if crouchReleaseTimer >= 0.1:
				isCrouching = false
		else:
			crouchReleaseTimer = 0.0
	
	isWalking = is_on_floor() and Input.get_vector("left", "right", "up", "down").length() > 0.1
	
	isStanding = not isWalking and is_on_floor()
	
	isSliding = isSprinting and isCrouching
	
	isJumping = not is_on_floor()
	
	if is_on_floor():
		if Input.get_vector("left", "right", "up", "down").length() > 0.1:
			isWalking = true
			isStanding = false
		else:
			isStanding = true
			isWalking = false
	else:
		isJumping = true

func handle_state_behavior():
	if isStanding:
		handle_height(false)
	if isWalking:
		speed = SPEEDS["walk"]
		handle_height(false)
	if isSprinting:
		speed = SPEEDS["sprint"]
	if isCrouching:
		speed = SPEEDS["crouch"]
		handle_height(true)
	if isSliding:
		speed = SPEEDS["slide"]
		handle_height(true)

func handle_direction() -> String:
	var forward = head.global_transform.basis.z.normalized() * -1 

	# Determine the direction based on the forward vector
	var degrees = rad_to_deg(atan2(forward.x, forward.z)) 

	if degrees < 0:
		degrees += 360
	elif degrees > 360:
		degrees -= 360  

	if degrees >= 337.5 or degrees < 22.5:
		return "N"
	elif degrees >= 22.5 and degrees < 67.5:
		return "NE"
	elif degrees >= 67.5 and degrees < 112.5:
		return "E"
	elif degrees >= 112.5 and degrees < 157.5:
		return "SE"
	elif degrees >= 157.5 and degrees < 202.5:
		return "S"
	elif degrees >= 202.5 and degrees < 247.5:
		return "SW"
	elif degrees >= 247.5 and degrees < 292.5:
		return "W"
	elif degrees >= 292.5 and degrees < 337.5:
		return "NW"
	else:
		return ""

func handle_mouselook(event: InputEvent):
	head.rotate_y(-event.relative.x * (sensitivity / 1000))
	cam.rotate_x(-event.relative.y * (sensitivity / 1000))
	cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(lowerCameraClamp), deg_to_rad(higherCameraClamp))
	
	mouseMovement = Vector2.ZERO

func handle_movement(delta: float):
	var input = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input.x, 0, input.y)).normalized()
	
	if is_on_floor():
		if direction != Vector3.ZERO:
			velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
		else:
			# Inertia
			velocity.x = lerp(velocity.x, 0.0, deceleration * delta)
			velocity.z = lerp(velocity.z, 0.0, deceleration * delta)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, airControl * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, airControl * delta)

func handle_jumping(delta: float):
	if is_on_floor():
		coyoteTime = coyoteTimeDur
	else:
		velocity.y -= gravity * gravityMult * delta
		
		if coyoteTime > 0:
			coyoteTime -= delta
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyoteTime > 0:
			velocity.y = jumpVelocity
			coyoteTime = 0

func handle_fov(delta):
	var targetFOV = fov + (fovChange * (1 if isSprinting else 0))
	cam.fov = lerp(cam.fov, targetFOV, 8.0 * delta)
	
	var target_rotation = deg_to_rad(900) if isSliding else cam.rotation_degrees.x
	cam.rotation_degrees.x = lerp(cam.rotation_degrees.x, target_rotation, 8.0 * delta)

func handle_height(crouching: bool):
	var capsule_shape = hitbox.shape as CapsuleShape3D
	
	if crouching:
		# capsule_shape.height = apply_over_time(capsule_shape.height, 0.5, 0.15, "subtract")
		capsule_shape.height = 0.5
	else: 
		# capsule_shape.height = apply_over_time(capsule_shape.height, 1, 0.15, "add")
		capsule_shape.height = 1
	hitbox.shape = capsule_shape

func emit_debug():
	debug_info.emit(
		global_transform.origin, 
		mouseMovement, 
		velocity, 
		handle_direction(), 
		fps,
		(abs(velocity.x) + abs(velocity.z))
		)
