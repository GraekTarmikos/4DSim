extends MeshInstance3D
var planeNode

# Called when the node enters the scene tree for the first time.
func _ready():
	
	planeNode = get_node("../Plane3D")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var v = planeNode.plane.Normal
	var o = planeNode.plane.Point
	mesh.clear_surfaces()
	var mesh_arr=[]
	var mesh_vertices = PackedVector3Array()
	var mesh_indices = PackedInt32Array()
	mesh_arr.resize(Mesh.ARRAY_MAX)
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	#st.set_uv(Vector2(0, 0))
	st.set_color(Color(0,1,0))
	st.add_vertex(o)
	st.add_vertex(o+v)
		
	mesh = st.commit()
