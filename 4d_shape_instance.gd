extends Node3D
enum MODE {SELF, SHARED}
enum SHAPE {CUBE, TETRAHEDRON, TESSERACT, HYPERSPHERE, BRIDGE, PENTACHORON, ICOSITETRACHORON, LONG_SPHERE, TEAPOT}

@export var plane_mode = MODE.SELF
@export var shape_mode = MODE.SELF
@export var shape = SHAPE.TESSERACT
@export var rot = [0,0,0,0]
@export var move = [0,0,0,0]
@export var pendulum = {"yes": false, "axis": 0, "cyclespeed": 2, "distance": 4, "speed" : 1}
@export var wireframeEnabled = false

#@export var shape
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(ev):
	if Input.is_key_pressed(KEY_F2) and shape_mode == MODE.SELF:
		wireframeEnabled = !wireframeEnabled
