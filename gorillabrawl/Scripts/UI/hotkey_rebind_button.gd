extends Control

@onready var label = $HBoxContainer/Label
@onready var button = $HBoxContainer/Button

@export var action_name : String = "up"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()

func set_action_name() -> void:
	label.text = "Unassigned"
	
	match action_name:
		"up":
			label.text = "Move Forward"
		"down":
			label.text = "Move Backward"
		"left":
			label.text = "Move Left"
		"right":
			label.text = "Move Right"
		"jump":
			label.text = "Jump"
		"sprint":
			label.text = "Sprint"
		"crouch":
			label.text = "Crouch"
		"menu":
			label.text = "Menu"

func set_text_for_key() -> void:
	var action_events = InputMap.action_get_events(action_name)
	if action_events.size() > 0:
		var action_event = action_events[0]
		var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
		
		button.text = "%s" % action_keycode
	else:
		button.text = "No key assigned"

func _on_button_toggled(toggled_on):
	if toggled_on:
		button.text = "Press any key..."
		set_process_unhandled_key_input(toggled_on)
		
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
	else:
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
		
		set_text_for_key()

func _unhandled_key_input(event):
	rebind_action_key(event)
	button.button_pressed = false

func rebind_action_key(event) -> void:
	var is_duplicate = false
	var action_keycode = OS.get_keycode_string(event.physical_keycode)
	
	for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				if i.button.text == "%s" % action_keycode:
					is_duplicate = true
					break
	if not is_duplicate:
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, event)
		
		set_process_unhandled_key_input(false)
		set_text_for_key()
		set_action_name()
	
