extends MeshInstance3D


var planeNode
var shapeNode
var shape3D
var moved

func project_3D_coords(v,a):
	var res = []
	for i in range(a.size()):
		var newv1 = Vector3(v[i][0],0,v[i][2])
		for j in a[i]:
			var newv2 = Vector3(v[j][0],0,v[j][2])
			res.append(newv1)
			res.append(newv2)
		#var newv1 = Vector3(v[ver[0]][0],0,v[ver[0]][2])
		#var newv2 = Vector3(v[ver[1]][0],0,v[ver[1]][2])
	return res
# Called when the node enters the scene tree for the first time.
func _ready():
	
	shapeNode = get_node("../3DShape")
#	shape3D = shapeNode.shape
#	moved = shapeNode.movedWireframe

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shape3D = shapeNode.shape
	moved = shapeNode.movedWireframe
	if(moved):
		shapeNode.movedWireframe = false
		mesh.clear_surfaces()
		var mesh_arr=[]
		var mesh_vertices = PackedVector3Array()
		var mesh_indices = PackedInt32Array()
		mesh_arr.resize(Mesh.ARRAY_MAX)
		
		var vertices = shape3D.vertices
		var edges = shape3D.wireframe
		
		var projected_vertices = project_3D_coords(vertices, edges)
		
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_LINES)
		st.set_uv(Vector2(0, 0))

		for v in projected_vertices:
			st.add_vertex(v)
			
		mesh = st.commit()
	
