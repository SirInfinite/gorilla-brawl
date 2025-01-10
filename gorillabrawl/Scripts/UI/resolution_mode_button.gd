extends Control

@onready var option_button = $HBoxContainer/OptionButton

const resolution_dict : Dictionary = {
	"2560 x 1440": Vector2i(2560, 1440),
	"1920 x 1080": Vector2i(1920, 1080),
	"1600 x 900": Vector2i(1600, 900),
	"1280 x 720": Vector2i(1280, 720),
	"800 x 600": Vector2i(800, 600),
	"1 x 1 (please dont)": Vector2i(1, 1)
}

func _ready():
	add_resolution_items()

func add_resolution_items() -> void:
	for resolution_size_text in resolution_dict:
		option_button.add_item(resolution_size_text)

func _on_resolution_selected(index: int) -> void:
	DisplayServer.window_set_size(resolution_dict.values()[index])
	centre_window()

func centre_window():
	var current_screen = DisplayServer.window_get_current_screen()
	var screen_position = DisplayServer.screen_get_position(current_screen)
	var screen_size = DisplayServer.screen_get_size(current_screen)
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(screen_position + screen_size / 2 - window_size / 2)
