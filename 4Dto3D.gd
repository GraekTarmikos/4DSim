extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(ev):
	if ev.is_action_pressed("ui_cancel"):
		get_tree().quit() # Quits the game
	if Input.is_key_pressed(KEY_F9):
		get_tree().change_scene_to_file("res://3dto2d.tscn")
	if Input.is_key_pressed(KEY_F10):
		get_tree().change_scene_to_file("res://4dto3D.tscn")
	if Input.is_key_pressed(KEY_F11):
		get_tree().change_scene_to_file("res://Levels/Main/L_Main.tscn")
