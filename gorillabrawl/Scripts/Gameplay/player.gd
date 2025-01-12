extends CharacterBody3D

signal debug_info

# References
@onready var head := $Head
@onready var cam := $Head/Camera3D
@onready var hitbox := $CollisionShape3D
@onready var body := $MeshInstance3D
@onready var roofRaycast = $RoofRaycast

# States
var states = {
	"isStanding": false,
	"isWalking": false,
	"isSprinting": false,
	"isJumping": false,
	"isCrouching": false,
	"isSliding": false
}

@export_category("Locomotion")
@export var walk_speed = 5.0
@export var acceleration := 15.0
@export var deceleration := 8.5
var speed : float

@export_category("Sprinting")
@export var do_sprint = true
@export var sprintSpeed = 8.0

@export_category("Crouching")
@export var do_crouch = true
@export var crouch_speed = 3.0
var crouch_release_timer := 0.0

@export_category("Sliding")
@export var do_slide = true
@export var slide_speed = 12.0

@export_category("Jumping")
const gravity := 9.8 # m/s^2
@export var gravity_mult := 1.0
@export var jump_velocity := 4.5
@export var air_control := 2.0
@export var coyote_time_duration := 0.1
@export var max_jumps := 2
var coyote_time := 0.0
var jump_count := 0

@export_category("Camera")
@export var sensitivity := 0.003
var min_pitch = -60
var max_pitch = 85
var mouse_movement := Vector2.ZERO

@export_category("FOV Effects")
@export var do_fov_effects = true
@export var fov := 80.0
@export var fov_change := 1.25

# Miscellaneous
var fps : float

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	velocity = Vector3.ZERO

func _process(_delta : float):
	fps = Engine.get_frames_per_second()

func _physics_process(delta: float):
	handle_movement(delta)
	handle_jumping(delta)
	
	handle_state(delta)
	handle_state_behavior(delta)
	
	if do_fov_effects:
		handle_fov(delta)
	
	move_and_slide()
	
	emit_debug()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			handle_mouselook(event)
			mouse_movement = event.relative

func handle_state(delta: float):
	states["isSprinting"] = do_sprint && Input.is_action_pressed("sprint")
	
	if do_crouch:
		if Input.is_action_pressed("crouch"):
			states["isCrouching"] = true
		else:
			if not roofRaycast.is_colliding():
				crouch_release_timer += delta
				if crouch_release_timer >= 0.1:
					states["isCrouching"] = false
			else:
				crouch_release_timer = 0.0
	
	states["isWalking"] = is_on_floor() and Input.get_vector("left", "right", "up", "down").length() > 0.1
	
	states["isStanding"] = not states["isWalking"] and is_on_floor()
	
	states["isSliding"] = do_slide && is_on_floor() && (states["isSprinting"] and states["isCrouching"])
	
	states["isJumping"] = not is_on_floor()

func handle_state_behavior(delta: float):
	handle_height(delta)
	if ["isStanding"]:
		fov_change = 0.0
	if states["isWalking"]:
		speed = walk_speed
		fov_change = 0.0
	if states["isSprinting"]:
		speed = sprintSpeed
		fov_change = 15.0
	if states["isCrouching"]:
		speed = crouch_speed
		fov_change = -10.0
	if states["isSliding"]:
		speed = slide_speed

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
	head.rotate_y(-event.relative.x * sensitivity)
	cam.rotate_x(-event.relative.y * sensitivity)
	cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	
	mouse_movement = Vector2.ZERO

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
		velocity.x = lerp(velocity.x, direction.x * speed, air_control * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, air_control * delta)

func handle_jumping(delta: float):
	if is_on_floor():
		coyote_time = coyote_time_duration
		jump_count = 0
	else:
		velocity.y -= gravity * gravity_mult * delta
		
		if coyote_time > 0:
			coyote_time -= delta
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_time > 0:
			velocity.y = jump_velocity
			coyote_time = 0  
		elif jump_count < max_jumps - 1:
			velocity.y = jump_velocity
			jump_count += 1

func handle_fov(delta: float):
	var targetFOV = fov + fov_change
	cam.fov = lerp(cam.fov, targetFOV, 8.0 * delta)
	
	var target_rotation = deg_to_rad(-10) if states["isSliding"] else cam.rotation_degrees.x
	cam.rotation_degrees.x = lerp(cam.rotation_degrees.x, target_rotation, 8.0 * delta)

func handle_height(delta: float):
	var capsule_shape = hitbox.shape
	
	capsule_shape.height = lerp(capsule_shape.height, 0.5 if states["isCrouching"] else (0.4 if states["isSliding"] else 1.0), 10.0 * delta)

func emit_debug():
	debug_info.emit(
		global_transform.origin, 
		mouse_movement, 
		states,
		velocity, 
		handle_direction(), 
		fps,
		(abs(velocity.x) + abs(velocity.z))
		)
