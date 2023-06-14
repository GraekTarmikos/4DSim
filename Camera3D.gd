extends Camera3D

var last_mouse_pos = Vector2.ZERO

func _ready():
	global_transform.origin = Vector3(0, 0, 5) # set initial camera position

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_delta = event.relative
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			var rot_x = Basis(Vector3.UP, -mouse_delta.x * 0.003)
			var rot_y = Basis(Vector3.RIGHT, mouse_delta.y * 0.003)
			look_at(Vector3(0,0,0))
			global_transform.origin = rot_y * (rot_x *(global_transform.origin))
