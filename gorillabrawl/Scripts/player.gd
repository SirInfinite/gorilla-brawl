extends CharacterBody3D

signal debug_info

@export_category("States")
enum PlayerState { IDLE, WALKING, SPRINTING, JUMPING, FALLING, CROUCHING, SLIDING }
@export var current_state : PlayerState

@export_category("References")
@onready var head = $Head
@onready var cam = $Head/Camera3D
@onready var hitbox = $CollisionShape3D
@onready var body = $MeshInstance3D

@export_category("Camera")
@export var sensitivity := 1.0
@export var fov := 75.0
@export var fov_change := 1.5
var mouse_movement := Vector2.ZERO

@export_category("Walking")
@export var speed := 0.0
@export var friction := 10.0
const SPEEDS = {
	"walk": 5.0,
	"sprint": 8.0,
	"crouch": 3.0,
	"slide": 12.0
}

@export_category("Jumping")
const gravity := 9.8 # m/s^2
@export var jump_velocity := 4.5
@export var air_control := 3.0

@export_category("Miscellaneous")
var fps : float

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta : float):
	fps = Engine.get_frames_per_second()

func _physics_process(delta: float):
	handle_movement(delta)
	handle_jumping(delta)
	handle_state()
	handle_state_behavior(current_state)
	handle_fov(delta)
	
	move_and_slide()
	
	emit_debug()
	mouse_movement = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			handle_mouselook(event)
			mouse_movement = event.relative

func is_state(state: PlayerState) -> bool:
	return current_state == state

func handle_state_behavior(state: PlayerState):
	match state:
		PlayerState.IDLE:
			speed = 0.0
			handle_height(false)
			return "IDLE"
		PlayerState.WALKING:
			speed = SPEEDS["walk"]
			handle_height(false)
			return "WALKING"
		PlayerState.SPRINTING:
			speed = SPEEDS["sprint"]
			return "SPRINTING"
		PlayerState.JUMPING:
			return "JUMPING"
		PlayerState.FALLING:
			return "FALLING"
		PlayerState.CROUCHING:
			speed = SPEEDS["crouch"]
			handle_height(true)
			return "CROUCHING"
		PlayerState.SLIDING:
			return "SLIDING"

func get_direction() -> String:
	var forward = head.global_transform.basis.z.normalized() * -1 

	# Determine the direction based on the forward vector
	var degrees = rad_to_deg(atan2(forward.x, forward.z)) 
	var direction = ""

	if degrees < 0:
		degrees += 360
	elif degrees > 360:
		degrees -= 360  

	if degrees >= 337.5 or degrees < 22.5:
		direction = "N"
	elif degrees >= 22.5 and degrees < 67.5:
		direction = "NE"
	elif degrees >= 67.5 and degrees < 112.5:
		direction = "E"
	elif degrees >= 112.5 and degrees < 157.5:
		direction = "SE"
	elif degrees >= 157.5 and degrees < 202.5:
		direction = "S"
	elif degrees >= 202.5 and degrees < 247.5:
		direction = "SW"
	elif degrees >= 247.5 and degrees < 292.5:
		direction = "W"
	elif degrees >= 292.5 and degrees < 337.5:
		direction = "NW"

	return direction

func handle_mouselook(event: InputEvent):
	head.rotate_y(-event.relative.x * (sensitivity / 1000))
	cam.rotate_x(-event.relative.y * (sensitivity / 1000))
	cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func handle_movement(delta: float):
	var input = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input.x, 0, input.y)).normalized()
	input = input.normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, friction * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, friction * delta)
	else:
		# Inertia
		velocity.x = lerp(velocity.x, direction.x * speed, air_control * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, air_control * delta)

func handle_jumping(delta: float):
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			# Handle jump
			velocity.y = jump_velocity
	else:
		# Add the gravity
		velocity.y -= gravity * delta

func handle_state():
	if is_on_floor():
		if Input.is_action_pressed("crouch"):
			current_state = PlayerState.SLIDING if Input.is_action_pressed("sprint") else PlayerState.CROUCHING
		elif velocity.length() > 0.25:
			current_state = PlayerState.SPRINTING if Input.is_action_pressed("sprint") else PlayerState.WALKING
		else:
			current_state = PlayerState.IDLE
	else:
		current_state = PlayerState.JUMPING if velocity.y > 0 else PlayerState.FALLING

func handle_fov(delta):
	var velocity_clamped = clamp(velocity.length(), 0.5, SPEEDS["sprint"] * 2)
	var target_fov = fov + (fov_change * velocity_clamped * (1 if handle_state_behavior(current_state) == "SPRINTING" else 0))
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
		handle_state_behavior(current_state), 
		velocity, 
		get_direction(), 
		fps
		)
