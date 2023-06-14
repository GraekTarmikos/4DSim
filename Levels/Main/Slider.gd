extends HSlider

func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventMouse:
		#print(event.get_button_mask())
		if event.get_button_mask() == 2**(MOUSE_BUTTON_WHEEL_UP-1):
			var new_value = get_value() + 0.05
			set_value(new_value)
		if event.get_button_mask() == 2**(MOUSE_BUTTON_WHEEL_DOWN-1):
			var new_value = get_value() - 0.05
			set_value(new_value)
			
