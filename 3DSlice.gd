extends MeshInstance3D

var lastState = {"Point": Vector4(0,0,0,-500), "Vertex": Vector4(-10000,-10000,-10000,-10000)}

var shapeNode
var planeNode
var shape4D
var vertices4D
var tetras4D
var colors4D
var plane4D

var myMesh

var cells4D
var simplexcolors4D

#var sliced
var surfaceTools = []

var mutex
var num_threads = 10
var threads = []

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

func inv_rotate_vertex4_to_normal(vertex: Vector4, normal: Vector4):
#	var up = Vector3.UP
#	var axis = normal.cross(up).normalized()
#	var angle = acos(normal.dot(up))
#	if(axis==Vector3(0,0,0)):
#		return vertex
#	var rotation = Basis(axis, angle)
#	return rotation*(vertex)
	return vertex

func auxVecArrSub(vec4, array,idx):
	if(idx==0):
		return [vec4[0]-array[0],vec4[1]-array[1],vec4[2]-array[2],vec4[3]-array[3]]
	else:
		return Vector4(vec4[0]-array[0],vec4[1]-array[1],vec4[2]-array[2],vec4[3]-array[3])
func auxVecArrSum(vec4, array,idx):
	if(idx==0):
		return [vec4[0]+array[0],vec4[1]+array[1],vec4[2]+array[2],vec4[3]+array[3]]
	else:
		return Vector4(vec4[0]+array[0],vec4[1]+array[1],vec4[2]+array[2],vec4[3]+array[3])

func sumVecs(v4s):
	var res = Vector4(0,0,0,0)
	for i in v4s:
		res += i
	return res
		

func determinar_caso(positive,negative,zeros):
	var lado1
	var lado2
	if(positive>=negative):
		lado1 = positive
		lado2 = negative
	else:
		lado1 = negative
		lado2 = positive

	if(lado1==4):
		return 1
	if(lado1==3):
		if(lado2==1):
			return 2
		return 4
	if(lado1==2):
		if(lado2==2):
			return 3
		if(lado2==1):
			return 5
		return 6
	if(lado1==1):
		if(lado2==1):
			return 7
		return 8
	return 9
		
func intersection(tetrahedron, normal, distances, i, j):
	var t = distances[i] / (distances[i] - distances[j])
	var inter_p = auxVecArrSum(tetrahedron[i], t * (auxVecArrSub(tetrahedron[j],tetrahedron[i],1)),1)
	#rotaciono inversamente a normal, para que o resultado permaneca no plano y=0
	#inter_p = inv_rotate_vertex4_to_normal(inter_p,normal) # NAO IMPLEMENTADA AINDA
	#print(i,",",j)
	#cref.append(colors[i].lerp(colors[j],t))
	return inter_p

func compute_cross_section(tetrahedron, hyperplane_normal: Vector4, hyperplane_point: Vector4):
	var triangles = []
	var intercolors = []
#	var faces = []
	var dists = []
	
	var pos = []
	var neg = []
	var zer = []
	for idx in range(4):
		var dist = hyperplane_normal.dot(auxVecArrSub(tetrahedron[idx], hyperplane_point,1))
		dists.append(dist)
		if(dist>0):
			pos.append(idx)
		elif(dist<0):
			neg.append(idx)
		elif(dist==0):
			zer.append(idx)
#		faces.append([idx,(idx+1)%4,(idx+2)%4])

	var caso = determinar_caso(pos.size(),neg.size(),zer.size())
	#print(caso)
	if(caso==1): # 0
		pass
	if(caso==2): # 1
		triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[0],neg[0]))
		if(pos.size()>neg.size()):
			triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[1],neg[0]))
			triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[2],neg[0]))
		else:
			triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[0],neg[1]))
			triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[0],neg[2]))
	if(caso==3): # 2
		triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[0],neg[0]))
		triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[0],neg[1]))
		triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[1],neg[0]))
		
		triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[1],neg[1]))
		triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[0],neg[1]))
		triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[1],neg[0]))
	if(caso==4): # 0
		pass
	if(caso==5): # 1
		triangles.append(tetrahedron[zer[0]])
	#	intercolors.append(colors[zer[0]])
		triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[0],neg[0]))
		if(pos.size()>neg.size()):
			triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[1],neg[0]))
		else:
			triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[0],neg[1]))
	if(caso==6): # 0
		pass
	if(caso==7): # 1
		triangles.append(intersection(tetrahedron,hyperplane_normal,dists,pos[0],neg[0]))
		triangles.append(tetrahedron[zer[0]])
		triangles.append(tetrahedron[zer[1]])
	#	intercolors.append(colors[zer[0]])
	#	intercolors.append(colors[zer[1]])
	if(caso==8): # 1
		for v in zer:
			triangles.append(tetrahedron[v])
	#		intercolors.append(colors[v])
	if(caso==9): # 4
		for i in range(4):
			triangles.append(tetrahedron[i])
			triangles.append(tetrahedron[(i+1)%4])
			triangles.append(tetrahedron[(i+2)%4])
	#		intercolors.append(colors[i])
	#		intercolors.append(colors[(i+1)%4])
	#		intercolors.append(colors[(i+2)%4])
	
	return [triangles,intercolors]


func execute_in_parallel(vertices: Array, simplicia: Array, plane_normal: Vector4, plane_point: Vector4, simplexColors):
	var chunk_size = ceil(simplicia.size()/num_threads)
	var res = []
	for i in range(num_threads):
		var thread = threads[i]
		var start_index = i*chunk_size
		var cres = []
		var end_index = min((i + 1) * chunk_size, simplicia.size())
		var callable = slice_4d_shape_on_plane.bind(res, start_index,end_index,vertices4D,tetras4D,plane4D.Normal,plane4D.Point,simplexcolors4D)
		thread.start(callable)
	for thread in threads:
		thread.wait_to_finish()
	return res

func slice_4d_shape_on_plane(cres, start,end,vertices: Array, simplicia: Array, plane_normal: Vector4, plane_point: Vector4, simplexColors):
	var result = []
	var resultcolorsCells = []
	for i in range(start,end):
		var simplex = simplicia[i]
		var tetra = [vertices[simplex[0]],vertices[simplex[1]],vertices[simplex[2]],vertices[simplex[3]]]
		
		var inter = compute_cross_section(tetra, plane_normal,plane_point)
		var points = inter[0]
		if(simplexColors.size()>0):
			for j in range(points.size()):
				resultcolorsCells.append(simplexColors[i])

		for j in range(points.size()):
			result.append(Vector3(points[j][0],points[j][1],points[j][2]))
	mutex.lock()
	cres.append([result,resultcolorsCells])
	mutex.unlock()
	return

func build_surface(local_res,mv,mi,mc):
	var sliced = local_res[0]
	var slicedcolors = local_res[1]

	var sum = 0
#	print("AAA ",sliced.size())
	for i in range(sliced.size()):
		if(slicedcolors.size()>0):
			mc.append(slicedcolors[i])
		mv.append(sliced[i])
		mi.append(sum)
		sum+=1

#	FAZ OS TRIANGULOS COM A NORMAL OPOSTA
	for i in range(sliced.size()):
		
		if(slicedcolors.size()>0):
			mc.append(slicedcolors[sliced.size()-1-i])
		mv.append(sliced[sliced.size()-1-i])
		mi.append(sum)
		sum+=1
		
	return

# Called when the node enters the scene tree for the first time.
func _ready():
	planeNode = get_node("../../Hyperplane")
	shapeNode = get_node("../4DShape")
	shape4D = shapeNode.shape
	tetras4D = shape4D.triangles
	simplexcolors4D = shape4D.simplexColors
	mutex = Mutex.new()
	myMesh = ArrayMesh.new()
	mesh = myMesh
	for i in range(num_threads):
		threads.append(Thread.new())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(shapeNode.changedShape):
		shape4D = shapeNode.shape
		tetras4D = shape4D.triangles
		simplexcolors4D = shape4D.simplexColors
		shapeNode.changedShape = false
	plane4D = planeNode.plane
	vertices4D = shapeNode.shape.vertices
	if(plane4D.Point[3]==lastState.Point[3]) and vertices4D[0] == lastState.Vertex:
		return
	lastState.Point = plane4D.Point
	lastState.Vertex = vertices4D[0]

		
	
	mesh.clear_surfaces()
	var mesh_vertices = PackedVector3Array()
	var mesh_indices = PackedInt32Array()
	
	var mv = []
	var mi = []
	var mc = []
	for i in range(num_threads):
		mv.append(PackedVector3Array())
		mi.append(PackedInt32Array())
		mc.append(PackedColorArray())
	
		
	
#	var res = slice_4d_shape_on_plane(vertices4D,tetras4D,plane4D.Normal,plane4D.Point,simplexcolors4D)
	var res = execute_in_parallel(vertices4D,tetras4D,plane4D.Normal,plane4D.Point,simplexcolors4D)

	for i in range(num_threads):
#		var st = surfaceTools[i]
		
		var callable = build_surface.bind(res[i],mv[i],mi[i],mc[i])
		var thread = threads[i]
		thread.start(callable)

	for thread in threads:
		thread.wait_to_finish()
		
		
#	for i in range(num_threads):
#		if(mi[i].size()==0):
#			print(i)
#	for local_res in res:
#		sliced = local_res[0]
#		var slicedcolors = local_res[1]
#
#		for i in range(sliced.size()):
#			if(slicedcolors.size()>0):
#				st.set_color(slicedcolors[i])
#			st.add_vertex(sliced[i])
#
##		FAZ OS TRIANGULOS COM A NORMAL OPOSTA
#		for i in range(sliced.size()):
#			if(slicedcolors.size()>0):
#				st.set_color(slicedcolors[sliced.size()-1-i])
#			st.add_vertex(sliced[sliced.size()-1-i])

#	st.generate_normals()
#	st.generate_tangents()
	
#	for st in surfaceTools:
#		mesh = st.commit()
	for i in range(num_threads):
		if(mv[i].size()>0):
			var mesh_arr=[]
			mesh_arr.resize(Mesh.ARRAY_MAX)
			mesh_arr[Mesh.ARRAY_VERTEX]=mv[i]
			mesh_arr[Mesh.ARRAY_INDEX]=mi[i]
			mesh_arr[Mesh.ARRAY_COLOR]=mc[i]
	#		print(i, " ", mv[i].size())
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,mesh_arr)
	
	if(self.get_children().size()>0):
		self.remove_child(self.get_child(0))
	if(res[0][0].size()>0):
		self.create_trimesh_collision()


func _exit_tree():
	for thread in threads:
		if(thread.is_started()):
			thread.wait_to_finish()
