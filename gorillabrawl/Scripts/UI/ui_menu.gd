extends Node2D

var show_ui = false
@onready var parent = $VBoxContainer

func _ready():
	set_process_input(true)
	for label in get_tree().get_nodes_in_group("debug_labels"):
		label.visible = false
	while parent:
		parent = parent.get_parent()

func _input(event):
	if event is InputEventKey && Input.is_action_just_pressed("debug"):
		show_ui = not show_ui
		toggle_debug_label(show_ui)

func toggle_debug_label(visibility: bool):
	for label in get_tree().get_nodes_in_group("debug_labels"):
		label.visible = visibility

func _on_player_debug_info(player_pos, mouse_pos, states, velocity, direction, fps, speed):
	$VBoxContainer/CoordinatesLabel.text = "Position: %.2v" % player_pos
	
	$VBoxContainer/MouseCoordinatesLabel.text = "Mouse: %.0v" % mouse_pos
	
	var active_states = []
	for state_name in states.keys():
		if states[state_name]:
			active_states.append(state_name)
	
	if active_states.size() == 0:
		$VBoxContainer/StatesLabel.text = "States: None"
	elif active_states.size() == 1:
		$VBoxContainer/StatesLabel.text = "States: " + active_states[0]
	else:
		$VBoxContainer/StatesLabel.text = "States: " + ", ".join(active_states)
	
	$VBoxContainer/VelocityLabel.text = "Velocity: %.2v" % velocity
	
	$FacingDirectionLabel.text = "Direction: %s" % direction
	
	$VBoxContainer/FPSLabel.text = "FPS: %.1f" % fps
	
	$VBoxContainer/SpeedLabel.text = "Speed: %.2f" % speed
