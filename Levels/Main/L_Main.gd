extends Node3D

@export var fast_close := true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if !OS.is_debug_build():
		fast_close = false
	
	if fast_close:
		print("** Fast Close enabled in the 'L_Main.gd' script **")
		print("** 'Esc' to close 'Shift + F1' to release mouse **")
	
	set_process_input(fast_close)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit() # Quits the game
	if Input.is_key_pressed(KEY_F9):
		get_tree().change_scene_to_file("res://3dto2d.tscn")
	if Input.is_key_pressed(KEY_F10):
		get_tree().change_scene_to_file("res://4dto3D.tscn")
#	if Input.is_key_pressed(KEY_F11):
#		get_tree().change_scene_to_file("res://Levels/Main/L_Main.tscn")
#	if event.is_action_pressed("change_mouse_input"):
#		match Input.get_mouse_mode():
#			Input.MOUSE_MODE_CAPTURED:
#				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#			Input.MOUSE_MODE_VISIBLE:
#				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Capture mouse if clicked on the game, needed for HTML5
# Called when an InputEvent hasn't been consumed by _input() or any GUI item
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		pass
#			if event.button_index == BUTTON_LEFT && event.pressed:
#				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
