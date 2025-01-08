extends CharacterBody3D

signal debug_info

@export_category("States")
@export var isStanding := false
@export var isWalking := false
@export var isSprinting := false
@export var isJumping := false
@export var isCrouching := false
@export var isSliding := false

@export_category("References")
@onready var head := $Head
@onready var cam := $Head/Camera3D
@onready var hitbox := $CollisionShape3D
@onready var body := $MeshInstance3D

@export_category("Camera")
@export var sensitivity := 1.0
@export var fov := 75.0
@export var fov_change := 1.5
var mouse_movement := Vector2.ZERO

@export_category("Walking")
@export var speed := 0.0
@export var acceleration := 20.0
@export var deceleration := 10.0
const SPEEDS := {
	"walk": 5.0,
	"sprint": 8.0,
	"crouch": 3.0,
	"slide": 12.0
}

@export_category("Jumping")
const gravity := 9.8 # m/s^2
@export var gravity_mult := 1.0
@export var jump_velocity := 4.5
@export var air_control := 3.0

@export_category("Miscellaneous")
var fps : float

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	velocity = Vector3.ZERO

func _process(_delta : float):
	fps = Engine.get_frames_per_second()

func _physics_process(delta: float):
	handle_movement(delta)
	handle_jumping(delta)
	handle_state()
	handle_state_behavior()
	handle_fov(delta)
	
	move_and_slide()
	
	emit_debug()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			handle_mouselook(event)
			mouse_movement = event.relative

func state_to_str():
	if isStanding:
		return "isStanding"
	if isWalking:
		return "isWalking"
	if isSprinting:
		return "isSprinting"
	if isJumping:
		return "isJumping"
	if isCrouching:
		return "isCrouching"
	if isSliding:
		return "isSliding"

func handle_state():
	isStanding = false
	isWalking = false
	isSprinting = false
	isJumping = false
	isCrouching = false
	isSliding = false
	
	if is_on_floor():
		if Input.is_action_pressed("crouch"):
			if Input.is_action_pressed("sprint"):
				isSliding = true 
			else:
				isCrouching = true
		elif Input.get_vector("left", "right", "up", "down").length() > 0.1:
			if Input.is_action_pressed("sprint"):
				isSprinting = true
			else:
				isWalking = true
		else:
			isStanding = true
	else:
		isJumping = true
		if Input.is_action_pressed("sprint"):
				isSprinting = true

func handle_state_behavior():
	if isStanding:
		speed = 0.0
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
	cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	mouse_movement = Vector2.ZERO

func handle_movement(delta: float):
	var input = Input.get_vector("left", "right", "up", "down").normalized()
	var direction = (head.transform.basis * Vector3(input.x, 0, input.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
		else:
			# Inertia
			velocity.x = lerp(velocity.x, 0.0, deceleration * delta)
			velocity.z = lerp(velocity.z, 0.0, deceleration * delta)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, air_control * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, air_control * delta)

func handle_jumping(delta: float):
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
	else:
		velocity.y -= gravity * gravity_mult * delta

func handle_fov(delta):
	var velocity_clamped = clamp(velocity.length(), 0.5, SPEEDS["sprint"] * 2)
	var target_fov = fov + (fov_change * velocity_clamped * (1 if isSprinting else 0))
	cam.fov = lerp(cam.fov, target_fov, 8.0 * delta)

func handle_height(crouching: bool):
	var capsule_shape = hitbox.shape as CapsuleShape3D
	if crouching:
		capsule_shape.height = 0.5
		body.scale = Vector3(1, 0.5, 1)
	else: 
		capsule_shape.height = 1.0
		body.scale = Vector3(1, 1, 1)
	hitbox.shape = capsule_shape

func emit_debug():
	debug_info.emit(
		global_transform.origin, 
		mouse_movement, 
		state_to_str(), 
		velocity, 
		handle_direction(), 
		fps
		)
