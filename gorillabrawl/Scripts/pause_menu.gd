extends Control

@onready var main = $".."
@onready var main_buttons = $PauseLogic/MarginContainer

func _ready():
	# options_menu.hide()
	pass

func _on_resume_pressed():
	print("resume pressed")
	main.pause()

func _on_quit_pressed():
	print("quit pressed")
	get_tree().quit()

func _on_options_pressed():
	print("options pressed")
	main_buttons.hide()
	# options_menu.show()

func show_pause_menu():
	main_buttons.show()
	self.show()
