extends CharacterBody3D

@export_category("States")
enum PlayerState { IDLE, WALKING, SPRINTING, JUMPING, CROUCHING, SLIDING }
@export var current_state = PlayerState.IDLE

@export_category("Camera")
@onready var head = $Head
@onready var cam = $Head/Camera3D
@export var sensitivity := 0.001
@export var fov := 75.0
@export var fov_change := 1.5

@export_category("Walking")
@export var speed := 0.0
@export var friction := 10.0
const walk_speed = 5.0
const sprint_speed = 8.0
const crouch_speed = 3.0

@export_category("Jumping")
@export var jump_velocity := 4.5
@export var gravity := 9.8
@export var air_control := 3.0

@export_category("UI")
var cursor_in_game := false
@export var UIMenuScene: PackedScene
var ui_menu = get_parent()
var key_inputs : Array = []

# @onready var input_timer = $InputTimer

signal coords_updated(player_pos: Vector3)
signal mouse_coords_updated(mouse_pos: Vector2)
signal state_updated(state: String)
signal velocity_updated(vel: Vector3)
signal direction_updated(direction_facing: String)
signal fps_updated(fps: int)
# signal inputs_updated(inputs: Array)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	coords_updated.connect(ui_menu._on_coords_updated)
	mouse_coords_updated.connect(ui_menu._on_mouse_coords_updated)
	state_updated.connect(ui_menu._on_state_updated)
	velocity_updated.connect(ui_menu._on_velocity_updated)
	direction_updated.connect(ui_menu._on_direction_updated)
	fps_updated.connect(ui_menu._on_fps_updated)
	# inputs_updated.connect(ui_menu._on_inputs_updated)
	
	# if input_timer:
		# input_timer.start()

func _process(_delta : float):
	var fps = Engine.get_frames_per_second()
	emit_signal("fps_updated", fps)
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if is_on_floor():
		if velocity.length() > 0.25:
			if speed == sprint_speed:
				current_state = PlayerState.SPRINTING
			else:
				current_state = PlayerState.WALKING
		else:
			current_state = PlayerState.IDLE
	else:
		current_state = PlayerState.JUMPING
	
	var direction = get_direction()
	emit_signal("direction_updated", direction)
	
	emit_signal("coords_updated", self.transform.origin)
	emit_signal("mouse_coords_updated", get_viewport().get_mouse_position())
	emit_signal("state_updated", state_to_string(current_state))
	emit_signal("velocity_updated", velocity)
	
	# if input_timer.is_timeout():
		# emit_signal("inputs_updated", key_inputs)
		# key_inputs.clear()

func _physics_process(delta: float):
	# Handle sprint
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	else:
		speed = walk_speed

	# Get the input direction and handle the movement/deceleration
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, friction * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, friction * delta)
		
		if Input.is_action_just_pressed("jump"):
			# Handle jump
			velocity.y = jump_velocity
	else:
		# Add the gravity
		velocity += get_gravity() * delta
		
		# Inertia
		velocity.x = lerp(velocity.x, direction.x * speed, air_control * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, air_control * delta)
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			key_inputs.append(event.scancode)
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			head.rotate_y(-event.relative.x * sensitivity)
			cam.rotate_x(-event.relative.y * sensitivity)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func update_state(new_state: PlayerState):
	current_state = new_state

func state_to_string(state: PlayerState):
	match state:
		PlayerState.IDLE:
			return "IDLE"
		PlayerState.WALKING:
			return "WALKING"
		PlayerState.SPRINTING:
			return "SPRINTING"
		PlayerState.JUMPING:
			return "JUMPING"
		PlayerState.CROUCHING:
			return "CROUCHING"
		PlayerState.SLIDING:
			return "SLIDING"

func get_direction() -> String:
	var forward = head.transform.basis.z
	var right = head.transform.basis.x
	if forward.z > 0:
		return "N"
	elif forward.z < 0:
		return "S"
	elif right.x > 0:
		return "E"
	else:
		return "W"
