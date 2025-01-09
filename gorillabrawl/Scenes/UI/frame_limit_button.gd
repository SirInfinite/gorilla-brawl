extends Control

@onready var h_slider = $HBoxContainer/HSlider
@onready var value_label = $HBoxContainer/ValueLabel

func _on_slider_drag_ended(value_changed):
	if h_slider.value == 0:
		Engine.max_fps = 1
		value_label.text = "1"
	else:
		Engine.max_fps = h_slider.value
		value_label.text = str(h_slider.value)
