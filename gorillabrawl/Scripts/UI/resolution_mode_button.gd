extends Control

@onready var option_button = $HBoxContainer/OptionButton

const resolution_dict : Dictionary = {
	"2560 x 1440" : Vector2i(2560, 1440),
	"1920 x 1200" : Vector2i(1920, 1200),
	"1920 x 1080" : Vector2i(1920, 1080),
	"1760 x 990" : Vector2i(1760, 990),
	"1680 x 1050" : Vector2i(1680, 1050),
	"1600 x 1200" : Vector2i(1600, 1200),
	"1600 x 900" : Vector2i(1600, 900),
	"1440 x 1050" : Vector2i(1440, 1050),
	"1440 x 900" : Vector2i(1440, 900),
	"1366 x 768" : Vector2i(1366, 768),
	"1280 x 1024" : Vector2i(1280, 1024),
	"1280 x 960" : Vector2i(1280, 960),
	"1280 x 800" : Vector2i(1280, 800),
	"1280 x 720" : Vector2i(1280, 720),
	"1152 x 864" : Vector2i(1152, 864),
	"1152 x 634" : Vector2i(1152, 634),
	"1024 x 768" : Vector2i(1024, 768),
	"854 x 480" : Vector2i(854, 480),
	"800 x 600" : Vector2i(800, 600),
	"720 x 400" : Vector2i(720, 400),
	"640 x 480" : Vector2i(640, 480),
	"1 x 1 (please dont)" : Vector2i(1, 1)
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
	var centre_screen = DisplayServer.screen_get_position() + DisplayServer.screen_get_size()/2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(centre_screen - window_size/2)
