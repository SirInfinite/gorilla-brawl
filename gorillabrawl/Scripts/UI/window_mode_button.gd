extends Control

@onready var option_button = $HBoxContainer/OptionButton

const window_mode_array : Array[String] = [
	"Fullscreen",
	"Windowed",
	"Borderless Windowed",
	"Borderless Fullscreen"
]

func _ready():
	add_window_mode_items()

func add_window_mode_items() -> void:
	for window_mode in window_mode_array:
		option_button.add_item(window_mode)

func _on_window_mode_selected(index: int) -> void:
	match index:
		0: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2: # Borderless Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3: # Borderless Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	
