extends Node
enum {SELF,SHARED}

# MODE = 0 -> Plano controlado com Ctrl + AZ / SX / DC / FV / GB
# Mode = 1 -> Normal do plano nao se mexe, valor w do plano controlado pelo slider na cena acima
var mode = SELF
var plane = {"Normal": Vector4(0,0,0,1),"Point" : Vector4(0,0,0,0)}
#var shapeNode
func movePlane(plane,amount):
	plane.Point[0]+=amount[0]
	plane.Point[1]+=amount[1]
	plane.Point[2]+=amount[2]
	plane.Point[3]+=amount[3]
	return

func rotatePlane(plane,axis_index,degrees):
	var rotation_axis = Vector3.ZERO
	rotation_axis[axis_index] = 1.0
	var basis = Basis()
	basis = basis.rotated(rotation_axis, deg_to_rad(degrees)) # rotate around Y axis
	plane.Normal = basis*(plane.Normal)
	return


# Called when the node enters the scene tree for the first time.
func _ready():
	#shapeNode = get_node("../3DShape")
	var shape4DNode = get_node("..")
	mode = shape4DNode.plane_mode



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(mode==1):
		plane.Point[3]=get_node("../../HSlider").get_value()


func _input(ev):
	if(mode==0):
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
			movePlane(plane,[0,0,0,0.04])
		elif Input.is_key_pressed(KEY_B) and ev.is_command_or_control_pressed():
			movePlane(plane,[0,0,0,-0.04])
