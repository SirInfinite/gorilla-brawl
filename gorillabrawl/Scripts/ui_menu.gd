extends Node2D

var show_ui = false

func _ready():
	for label in get_tree().get_nodes_in_group("debug_labels"):
		label.visible = false

func _input(event):
	if event is InputEventKey && Input.is_action_just_pressed("debug"):
		show_ui = !show_ui
		toggle_debug_label(show_ui)

func toggle_debug_label(visiblity: bool):
	for label in get_tree().get_nodes_in_group("debug_labels"):
		label.visible = visiblity

func _on_player_debug_info(player_pos, mouse_pos, state, velocity, direction, fps):
	$VBoxContainer/CoordinatesLabel.text = "Position: %.2v" % player_pos
	
	$VBoxContainer/MouseCoordinatesLabel.text = "Mouse: %.0v" % mouse_pos
	
	$VBoxContainer/CurrentStateLabel.text = "State: %s" % state

	$VBoxContainer/VelocityLabel.text = "Velocity: %.2v" % velocity
	
	$FacingDirectionLabel.text = "Direction: %s" % direction
	
	$VBoxContainer/FPSLabel.text = "FPS: %.1f" % fps