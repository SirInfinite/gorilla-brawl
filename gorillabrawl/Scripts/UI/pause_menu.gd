extends Control

@onready var options_menu = $OptionsMenu 
@onready var resume_button = $MarginContainer/VBoxContainer/Resume
@onready var options_button = $MarginContainer/VBoxContainer/Options
@onready var quit_button = $MarginContainer/VBoxContainer/Quit
@onready var main_buttons = $MarginContainer
var paused := false

func _ready():
	hide()  # Ensure the menu is hidden at the start
	options_menu.hide()

func _process(_delta):
	if Input.is_action_just_pressed("menu"):  # "menu" is the pause action
		if options_menu.visible == true:
			_on_exit_options_menu()
		else:
			toggle_pause()

func toggle_pause():
	paused = !paused
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		show()
		get_tree().paused = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		hide()
		get_tree().paused = false

func _on_resume_pressed():
	toggle_pause()

func _on_options_pressed():
	main_buttons.hide()
	options_menu.set_process(true)
	options_menu.show()

func _on_quit_pressed():
	get_tree().quit()

func _on_exit_options_menu() -> void:
	main_buttons.show()
	options_menu.hide()
