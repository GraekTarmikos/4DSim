extends MeshInstance3D

var shapeNode
var planeNode
var shape3D
var vertices3D
var tris3D
var colors3D
var plane3D

var sliced


func rotate_vertex_to_normal(vertex: Vector3, normal: Vector3) -> Vector3:
	var up = Vector3.UP
	var axis = up.cross(normal).normalized()
	var angle = acos(up.dot(normal))
	var rotation = Basis(axis, angle)
	return rotation*(vertex)
	
func inv_rotate_vertex_to_normal(vertex: Vector3, normal: Vector3) -> Vector3:
	var up = Vector3.UP
	var axis = normal.cross(up).normalized()
	var angle = acos(normal.dot(up))
	if(axis==Vector3(0,0,0)):
		return vertex
	var rotation = Basis(axis, angle)
	return rotation*(vertex)
	
func triangle_plane_intersection(triangle: Array, plane_normal: Vector3, plane_point: Vector3,colors) -> Array:
	# Find the intersection points of a triangle and a plane
	# triangle - array of three Vector3 points representing the vertices of the triangle
	# plane_normal - the normal vector of the plane
	# plane_point - any point on the plane

	
	var intersection_points = []
	var intercolors = []
	# Find the distance between the plane and each vertex of the triangle
	var distances = []
	for i in range(3):

		distances.append(plane_normal.dot(triangle[i] - plane_point))
	
	#print("D ",distances)
	# Check if the triangle is completely on one side of the plane
	if (distances[0] > 0 and distances[1] > 0 and distances[2] > 0) or (distances[0] < 0 and distances[1] < 0 and distances[2] < 0):
		return [intersection_points,intercolors]
	
	# Calculate the intersection points
	for i in range(3):
		var j = (i + 1) % 3
		if distances[i] * distances[j] < 0:
			var t = distances[i] / (distances[i] - distances[j])
			var inter_p = triangle[i] + t * (triangle[j] - triangle[i])
			
			#rotaciono inversamente a normal, para que o resultado permaneca no plano y=0
			inter_p = inv_rotate_vertex_to_normal(inter_p,plane_normal)
			
			intersection_points.append(inter_p)
			intercolors.append(colors[i].lerp(colors[j],t))
	
	return [intersection_points,intercolors]
	
func slice_3d_shape_on_plane(vertices: Array, triangles: Array, plane_normal: Vector3, plane_point: Vector3, colors) -> Array:
	var result = []
	var resultcolors = []
	var i = 0
	for triangle in triangles:
		
		var c = [colors[i/2],colors[i/2],colors[i/2]]
		if(len(colors)==len(triangles)):
			c = [colors[i],colors[i],colors[i]]
		i +=1
		var tri = [vertices[triangle[0]],vertices[triangle[1]],vertices[triangle[2]]]
#		var c = [colors[triangle[0]],colors[triangle[1]],colors[triangle[2]]] # Cores antigas
		var inter = triangle_plane_intersection(tri, plane_normal,plane_point,c)
		var points = inter[0]
		var intercolors = inter[1]
		if(points.size()==2):
			result.append(points[0])
			result.append(points[1])
			resultcolors.append(intercolors[0])
			resultcolors.append(intercolors[1])
		elif(points.size()==3):
			result.append(points[0])
			result.append(points[1])
			resultcolors.append(intercolors[0])
			resultcolors.append(intercolors[1])
			
			result.append(points[1])
			result.append(points[2])
			resultcolors.append(intercolors[1])
			resultcolors.append(intercolors[2])
			
			result.append(points[2])
			result.append(points[0])
			resultcolors.append(intercolors[2])
			resultcolors.append(intercolors[0])
	
	return [result,resultcolors]

# Called when the node enters the scene tree for the first time.
func _ready():
	planeNode = get_node("../../Plane3D")
	shapeNode = get_node("../3DShape")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var moved = shapeNode.moved2D
	shape3D = shapeNode.shape
	tris3D = shape3D.triangles
	colors3D = shape3D.colors
	if(moved):
		shapeNode.moved2D = false
		plane3D = planeNode.plane
		vertices3D = shapeNode.shape.vertices
		mesh.clear_surfaces()
		var mesh_arr=[]
		var mesh_vertices = PackedVector3Array()
		var mesh_indices = PackedInt32Array()
		mesh_arr.resize(Mesh.ARRAY_MAX)
		
		var st = SurfaceTool.new()
		
		var res = slice_3d_shape_on_plane(vertices3D,tris3D,plane3D.Normal,plane3D.Point,colors3D)
		sliced = res[0]
		var slicedcolors = res[1]
		#print(sliced)
		st.begin(Mesh.PRIMITIVE_LINES)
		st.set_uv(Vector2(0, 0))
		for i in range(sliced.size()):
			sliced.append(Vector3(sliced[i][0],sliced[i][1],sliced[i][2]-100))
			slicedcolors.append(slicedcolors[i])
		for i in range(sliced.size()):
			
			#st.add_vertex(Vector3(0,0,0))
			#st.add_vertex(Vector3(0.5,0,0))
			#st.add_vertex(Vector3(0.5,0,0.5))
			st.set_color(slicedcolors[i])
			st.add_vertex(sliced[i])

			
		#st.generate_normals()
		#st.generate_tangents()
		mesh = st.commit()
		
	
