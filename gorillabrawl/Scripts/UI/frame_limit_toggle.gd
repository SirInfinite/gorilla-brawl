extends Control

@onready var option_button = $HBoxContainer/OptionButton
@onready var frame_limit_button = $"../Frame_Limit_Button"

const frame_limit_toggle_array : Array = [
	"No",
	"Yes"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	add_choices()
	frame_limit_button.visible = false
	self.visible = true

func add_choices() -> void:
	for choice in frame_limit_toggle_array:
		option_button.add_item(choice)

func _on_choice_selected(index):
	match index:
		0: # No Frame Limit
			Engine.max_fps = 0
			frame_limit_button.hide()
		1: # Frame Limit
			frame_limit_button.show()
