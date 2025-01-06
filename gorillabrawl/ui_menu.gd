extends CanvasLayer

var show_ui = true

func _on_coords_updated(player_pos: Vector3):
	$VBoxContainer/CoordinatesLabel.text = "Position: %s" % str(player_pos)

func _on_mouse_coords_updated(mouse_pos: Vector2):
	$VBoxContainer/MousePositionLabel.text = "Mouse: %s" % str(mouse_pos)

func _on_state_updated(state: String):
	$VBoxContainer/CurrentStateLabel.text = "State: %s" % state

func _on_velocity_updated(vel: Vector3):
	$VBoxContainer/VelocityLabel.text = "Velocity: %s" % str(vel)

func _on_direction_updated(direction_facing: String):
	$VBoxContainer/DirectionFacingLabel.text = "Direction: %s" % direction_facing

func _on_fps_updated(fps: int):
	$VBoxContainer/FPSLabel.text = "FPS: %s" % str(fps)

'''func _on_inputs_updated(inputs: Array):
	$InputsLabel.text = "Inputs: %s" % str(inputs)

func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_F3:
		show_ui = not show_ui
		toggle_debug_labels_visibility(show_ui)

# Function to toggle visibility of the group 'debug_labels'
func toggle_debug_labels_visibility(visible: bool):
	for label in get_tree().get_nodes_in_group("debug_labels"):
		label.visible = visible'''
