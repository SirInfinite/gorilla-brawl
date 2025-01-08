extends Control

@onready var back_button = $MarginContainer/VBoxContainer/BackButton as Button

signal exit_options_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)

func _on_back_button_pressed():
	exit_options_menu.emit()
	set_process(false)
