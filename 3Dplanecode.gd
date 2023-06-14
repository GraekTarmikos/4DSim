extends CSGBox3D

var plane = {"Normal": Vector3(0,1,0),"Point" : Vector3(0,0,0)}
#var shapeNode
func movePlane(plane,amount):
	plane.Point[0]+=amount[0]
	plane.Point[1]+=amount[1]
	plane.Point[2]+=amount[2]
	return

func rotatePlane(plane,axis_index,degrees):
	var rotation_axis = Vector3.ZERO
	rotation_axis[axis_index] = 1.0
	var basis = Basis()
	basis = basis.rotated(rotation_axis, deg_to_rad(degrees)) # rotate around Y axis
	plane.Normal = basis*(plane.Normal)
	return


func rotateVector(vector,axis_index,degrees):
	var rotation_axis = Vector3.ZERO
	rotation_axis[axis_index] = 1.0
	var basis = Basis()
	basis = basis.rotated(rotation_axis, deg_to_rad(degrees)) # rotate around Y axis
	return basis*(vector)


# Called when the node enters the scene tree for the first time.
func _ready():
	
	rotatePlane(plane,0,0.01)
	transform.origin = plane.Point
	look_at(transform.origin+(plane.Normal))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	
	transform.origin = plane.Point

	look_at(transform.origin+(plane.Normal),Vector3.UP)

	pass

func _input(ev):
	if Input.is_key_pressed(KEY_Z) and ev.is_command_or_control_pressed():
		rotatePlane(plane,0,2)
	elif Input.is_key_pressed(KEY_A) and ev.is_command_or_control_pressed():
		rotatePlane(plane,0,-2)
	if Input.is_key_pressed(KEY_X) and ev.is_command_or_control_pressed():
		rotatePlane(plane,1,2)
	elif Input.is_key_pressed(KEY_S) and ev.is_command_or_control_pressed():
		rotatePlane(plane,1,-2)
	if Input.is_key_pressed(KEY_C) and ev.is_command_or_control_pressed():
		rotatePlane(plane,2,2)
	elif Input.is_key_pressed(KEY_D) and ev.is_command_or_control_pressed():
		rotatePlane(plane,2,-2)

	if Input.is_key_pressed(KEY_G) and ev.is_command_or_control_pressed():
		movePlane(plane,[0,0.04,0])
	elif Input.is_key_pressed(KEY_B) and ev.is_command_or_control_pressed():
		movePlane(plane,[0,-0.04,0])
