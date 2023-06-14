extends MeshInstance3D


var planeNode
var shapeNode
var rootNode
var shape4D
var enabled = true

# Multiplicacao de matrizes
func matrix_multiplication(A: Array, B: Array) -> Array:
	var result = []
	var rowsA = A.size()
	var colsA = A[0].size()
	var rowsB = B.size()
	var colsB = B[0].size()

	# check if matrices can be multiplied
	if colsA != rowsB:
		print("Matrices cannot be multiplied")
		return result

	# initialize the result matrix
	for i in range(rowsA):
		var row = []
		for j in range(colsB):
			row.append(0)
		result.append(row)

	# perform matrix multiplication
	for i in range(rowsA):
		for j in range(colsB):
			for k in range(colsA):
				result[i][j] += A[i][k] * B[k][j]

	return result

# Projeta uma única coordenada 4D para um hiperplano 3D
func project4Dto3D(v):
#	var c = [v[0],v[1],v[2],v[3]]
#	var projection_matrix = [        
#		[1, 0, 0, 0],
#		[0, 1, 0, 0],
#		[0, 0, 1, 0],
#		[0, 0, 0, 0]
#	]
#	#var projection_matrix = build_projection_matrix()
#
#	# Define the 4D homogeneous coordinate
#	var homogeneous_coord = [c]
#	# Multiply the projection matrix by the homogeneous coordinate
#	var projected_coord = matrix_multiplication(homogeneous_coord, projection_matrix)[0]
	
	# Normalize the projected coordinate
	#var normalized_coord = [projected_coord[0]/projected_coord[3], projected_coord[1]/projected_coord[3], projected_coord[2]/projected_coord[3]]
	#return normalized_coord
	var projected_coord = Vector3(v[0],v[1],v[2])
	return projected_coord

# Projeta uma lista de coordenadas 4D para um hiperplano 3D
func project_4D_coords(v):
	var pv = []
	for i in range(v.size()):
#		pv.append(vector3(v[i][0],v[i][1],v[i][2]))
#		var arr = [v[i][0],v[i][1],v[i][2],v[i][3]]
		pv.append(project4Dto3D(v[i]))
	return pv

# Recebe uma lista de coordenadas 4D "v" e a lista de conexoes/arestas "a" e gera os arrays para criar a superficie usando linhas
func generate_mesh_lines(v,a):
	var mesh_ver = PackedVector3Array()
	var mesh_idx = PackedInt32Array()
	var counter = 0
	
	for i in range(v.size()): # Para cada vertice i
		var curCoord = v[i]
		var curVector = Vector3(curCoord[0],curCoord[1],curCoord[2])
		
		for j in range(a[i].size()): # Para cada aresta j do vertice i
			if(a[i][j]>i): # Se essa o vertice destino ainda nao estiver sido computado (evitar arestas repetidas)
				
				var nxtCoord = v[a[i][j]]
				var nxtVector = Vector3(nxtCoord[0],nxtCoord[1],nxtCoord[2])
				
				mesh_ver.append(curVector)
				mesh_idx.append(counter)
				counter+=1
				mesh_ver.append(nxtVector)
				mesh_idx.append(counter)
				counter+=1
	return [mesh_ver, mesh_idx]

# Recebe uma lista de coordenadas 4D "v" e a lista de conexoes/arestas "a", projeta para 3D e gera os arrays para criar a superficie
func generate_projected_tesseract_mesh(v,a,w):

	var mesh_ver = PackedVector3Array()
	var mesh_idx = PackedInt32Array()
	var mesh_clr = PackedColorArray()
	var counter = 0
	
	for i in range(v.size()): # Para cada vertice i
		var curCoord = project4Dto3D(v[i])
		var curVector = Vector3(curCoord[0],curCoord[1],curCoord[2])
		
		for j in range(a[i].size()): # Para cada aresta j do vertice i
			if(a[i][j]>i): # Se essa o vertice destino ainda nao estiver sido computado (evitar arestas repetidas)
				
				var nxtCoord = project4Dto3D(v[a[i][j]])
				var nxtVector = Vector3(nxtCoord[0],nxtCoord[1],nxtCoord[2])
				
				var dist = v[i][3]-w
				var alpha = lerp(1.0,0.1,abs(dist/1.2))
				
				if(dist>0):
					mesh_clr.append(Color(1,0,0,alpha))
				else:
					mesh_clr.append(Color(0,0,1,alpha))
					
				mesh_ver.append(curVector)
				mesh_idx.append(counter)
				counter+=1
				
				dist = v[a[i][j]][3]-w
				alpha = lerp(1.0,0.1,abs(dist/1.2))
				if(dist>0):
					mesh_clr.append(Color(1,0,0,alpha))
				else:
					mesh_clr.append(Color(0,0,1,alpha))
				
				mesh_ver.append(nxtVector)
				mesh_idx.append(counter)
				counter+=1
	return [mesh_ver, mesh_idx, mesh_clr]
				


# Called when the node enters the scene tree for the first time.
func _ready():
	
	planeNode = get_node("../../Hyperplane")
	shapeNode = get_node("../4DShape")
	rootNode = get_node("../..")
	enabled = rootNode.wireframeEnabled
	shape4D = shapeNode.shape
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	enabled = rootNode.wireframeEnabled
	mesh.clear_surfaces()
	shape4D = shapeNode.shape
	if(enabled):
		var mesh_arr=[]
	#	var mesh_vertices = PackedVector3Array()
	#	var mesh_indices = PackedInt32Array()
		mesh_arr.resize(Mesh.ARRAY_MAX)
		
		var vertices = shape4D.vertices
		var edges = shape4D.wireframe
		var plane_w = planeNode.plane.Point[3]
		
		var st = SurfaceTool.new()
		
		if edges.size()!=0:
			#var projected_vertices = project_4D_coords(vertices)
			var tess_mesh = generate_projected_tesseract_mesh(vertices,edges, plane_w)
			st.begin(Mesh.PRIMITIVE_LINES)
			st.set_uv(Vector2(0, 0))

			for i in range(tess_mesh[0].size()):
				st.set_color(tess_mesh[2][i])
				st.add_vertex(tess_mesh[0][i])
			
			mesh = st.commit()
	#		mesh_arr[Mesh.ARRAY_VERTEX]=tess_mesh[0]
	#		mesh_arr[Mesh.ARRAY_INDEX]=tess_mesh[1]
	#		mesh_arr[Mesh.ARRAY_COLOR]=tess_mesh[2]
	#		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES,mesh_arr)
