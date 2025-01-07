extends Control

@onready var main = $"../.."
@onready var main_buttons = $MarginContainer

func _ready():
	# options_menu.hide()
	pass

func _on_resume_pressed():
	main.pause()

func _on_quit_pressed():
	get_tree().quit()

func _on_options_pressed():
	main_buttons.hide()
	# options_menu.show()

func show_pause_menu():
	main_buttons.show()
	self.show()
