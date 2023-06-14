extends CollisionShape2D

var shapeNode
var shape3DNode


func removeY(coords):
	var res = PackedVector2Array()
	var t = 65
	for i in coords:
		res.append(Vector2(i[0]*t+9*66,i[2]*t+9*66))
	return res
# Called when the node enters the scene tree for the first time.
func _ready():
	shapeNode = get_node("../../2DSlice")
	shape3DNode = get_node("../../3DShape")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(get_shape())
	var moved = shape3DNode.moved2Dcollision
	if(moved):
		shape3DNode.moved2Dcollision = false
		var points = removeY(shapeNode.sliced)
		var shape = ConcavePolygonShape2D.new()
		shape.set_segments(points)
		#print(shape.get_segments())
		set_shape(shape)
		#print(get_shape())
		#set_shape()
		#set_shape()
		#var a = Shape2D()
		#make_convex_from_siblings()
		#print(points)
