extends MeshInstance3D


func slice_4d_shape(shape_coords: Array, shape_links: Array, plane_normal: Vector4, plane_point: Vector4) -> Array:
	# First, we need to find all the 3D faces of the shape that intersect the plane
	var intersecting_faces = []
	for i in range(shape_coords.size()):
		var coords = shape_coords[i]
		var links = shape_links[i]
		# Check if this vertex is on the positive or negative side of the plane
		var newcoord = Vector4(coords[0]-plane_point[0],coords[1]-plane_point[1],coords[2]-plane_point[2],coords[3]-plane_point[3])
		var distance = newcoord.dot(plane_normal)
		if abs(distance) < 0.001:
			# The vertex is almost on the plane, so we consider it to be on the plane
			distance = 0.0
		var side = distance > 0.0
		# Now we look at each adjacent vertex and check if the edge intersects the plane
		for link in links:
			var linked_coords = shape_coords[link]
			var newlinked = Vector4(linked_coords[0] - plane_point[0],linked_coords[01] - plane_point[1],linked_coords[2] - plane_point[2],linked_coords[3] - plane_point[03])
			var linked_distance = newlinked.dot(plane_normal)
			if abs(linked_distance) < 0.001:
				linked_distance = 0.0
			var linked_side = linked_distance > 0.0
			if side != linked_side:
				# The edge intersects the plane, so we add this face to the list
				var face = [coords, linked_coords]
				# Now we need to find the two other vertices that complete the face
				for j in links:
					if j == i or j == link:
						continue
					var other_coords = shape_coords[j]
					var newother = Vector4(other_coords[0] - plane_point[0],other_coords[01] - plane_point[1],other_coords[2] - plane_point[2],other_coords[3] - plane_point[03])
					var other_distance = newother.dot(plane_normal)
					if abs(other_distance) < 0.001:
						other_distance = 0.0
					var other_side = other_distance > 0.0
					if side == other_side:
						face.append(other_coords)
				intersecting_faces.append(face)
	# Now we need to triangulate the intersecting faces to get a 3D mesh
	var mecha = []
	for face in intersecting_faces:
		# We assume the face is convex and triangulate it using a fan of triangles
		var centroid = Vector3(0.0, 0.0, 0.0)
		for coord in face:
			centroid = Vector3(centroid[0]+coord[0],centroid[1]+coord[1],centroid[2]+coord[2])
		centroid /= face.size()
		for i in range(1, face.size() - 1):
			#mesh.append([face[0], face[i], face[i + 1]])
			mecha.append(face[0])
			mecha.append(face[i])
			mecha.append(face[i+1])
	return mecha

# Rotaciona uma coordenada 4D no eixo "axis" (de 0-3 = x,y,z,w)
func rotate_4d_coord(coords: Vector4, axis: int, angle_degrees: float):
	
	var angle_radians = angle_degrees * PI / 180.0
	var cos_theta = cos(angle_radians)
	var sin_theta = sin(angle_radians)
	var rotation_matrix = []
	# Create the rotation matrix based on the given axis
	if axis == 0:
		rotation_matrix = [            
			[1, 0, 0, 0],
			[0, cos_theta, sin_theta, 0],
			[0, -sin_theta, cos_theta, 0],
			[0, 0, 0, 1]
		]
	elif axis == 1:
		rotation_matrix = [            
			[cos_theta, 0, -sin_theta, 0],
			[0, 1, 0, 0],
			[sin_theta, 0, cos_theta, 0],
			[0, 0, 0, 1]
		]
	elif axis == 2:
		rotation_matrix = [            
			[cos_theta, sin_theta, 0, 0],
			[-sin_theta, cos_theta, 0, 0],
			[0, 0, 1, 0],
			[0, 0, 0, 1]
		]
	elif axis == 3:
		rotation_matrix = [            
			[cos_theta, 0, 0, sin_theta],
			[0, 1, 0, 0],
			[0, 0, 1, 0],
			[-sin_theta, 0, 0, cos_theta]
		]

	# Multiply the coordinate by the rotation matrix
	var new_coord = [0,0,0,0]
	for i in range(4):
		var sum = 0
		for j in range(4):
			sum += rotation_matrix[i][j] * coords[j]
		new_coord[i] = sum
			
	
#    var new_coord = [        sum(rotation_matrix[i][j] * coord[j] for j in range(4))
#        for i in range(4)
#    ]
	
	return new_coord

# Rotaciona todas as coordenadas de uma forma
func rotate_4d_shape(coords: Array, axis_idx: int, angle_degrees: float):
	var result = []
	for i in range(coords.size()):
		var v4 = Vector4(coords[i][0],coords[i][1],coords[i][2],coords[i][3])
		result.append(rotate_4d_coord(v4,axis_idx,angle_degrees))

	return result
	
# Funcao para criar uma matriz de projeção, ainda preciso tentar entender se isso faz qualquer sentido mas pode ser util pra pesquisar sobre essas coisas
func build_projection_matrix() -> Array:
	# define the projection parameters
	var fov = 60.0
	var aspect_ratio = 16.0/9.0
	var near_clip = 0.1
	var far_clip = 100.0
	
	# calculate the projection matrix components
	var f = 1.0 / tan(fov * PI / 360.0)
	var z_range = near_clip - far_clip
	
	# build the projection matrix
	var projection_matrix = [
		[f/aspect_ratio, 0.0, 0.0, 0.0],
		[0.0, f, 0.0, 0.0],
		[0.0, 0.0, (far_clip + near_clip)/z_range, 2.0 * far_clip * near_clip / z_range],
		[0.0, 0.0, -1.0, 0.0]
	]
	
	return projection_matrix

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
func project4Dto3D(c: Array):
	var projection_matrix = [        
		[1, 0, 0, 0],
		[0, 1, 0, 0],
		[0, 0, 1, 0],
		[0, 0, 0, 0]
	]
	#var projection_matrix = build_projection_matrix()

	# Define the 4D homogeneous coordinate
	var homogeneous_coord = [c]
	# Multiply the projection matrix by the homogeneous coordinate
	var projected_coord = matrix_multiplication(homogeneous_coord, projection_matrix)[0]

	# Normalize the projected coordinate
	#var normalized_coord = [projected_coord[0]/projected_coord[3], projected_coord[1]/projected_coord[3], projected_coord[2]/projected_coord[3]]
	#return normalized_coord
	return projected_coord

# Projeta uma lista de coordenadas 4D para um hiperplano 3D
func project_4D_coords(v):
	var pv = []
	for i in range(v.size()):
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
func generate_projected_tesseract_mesh(v,a):
		
	var mesh_ver = PackedVector3Array()
	var mesh_idx = PackedInt32Array()
	var counter = 0
	
	for i in range(v.size()): # Para cada vertice i
		var curCoord = project4Dto3D(v[i])
		var curVector = Vector3(curCoord[0],curCoord[1],curCoord[2])
		
		for j in range(a[i].size()): # Para cada aresta j do vertice i
			if(a[i][j]>i): # Se essa o vertice destino ainda nao estiver sido computado (evitar arestas repetidas)
				
				var nxtCoord = project4Dto3D(v[a[i][j]])
				var nxtVector = Vector3(nxtCoord[0],nxtCoord[1],nxtCoord[2])
				
				mesh_ver.append(curVector)
				mesh_idx.append(counter)
				counter+=1
				mesh_ver.append(nxtVector)
				mesh_idx.append(counter)
				counter+=1
	return [mesh_ver, mesh_idx]
				

# Recebe uma lista de coordenadas e a magnitude da translação em cada eixo
# (Translacao apenas das coordenadas, essencialmente eh pra mover a origem da mesh)
func move(coords: Array, amount: Array) -> Array:
	for i in range(coords.size()):
		for j in range(4):
			coords[i][j]+=amount[j]
	return coords

func is_left_turn(a: Vector3, b: Vector3, c: Vector3) -> bool:
	var ab = b - a
	var ac = c - a
	var cross = ab.cross(ac)
	return cross.x >= 0 and cross.y >= 0 and cross.z >= 0

func compute_convex_hull(vertices: PackedVector3Array) -> PackedVector3Array:
	var hull = PackedVector3Array()
	
	# Find the leftmost point
	var leftmost = 0
	for i in range(vertices.size()):
		if vertices[i].x < vertices[leftmost].x:
			leftmost = i
			
	# Add the leftmost point to the hull and start wrapping
	var current = leftmost
	var next = 0
	var visited = PackedInt32Array()
	visited.push_back(current)
	
	while(true):
		# Find the next point on the hull
		next = (current + 1) % vertices.size()
		for i in range(vertices.size()):
			if i == current or i == next or visited.find(i) >= 0:
				continue
			if is_left_turn(vertices[current], vertices[next], vertices[i]):
				next = i
		
		# Add the next point to the hull
		visited.push_back(next)
		hull.append(vertices[next])
		current = next
		print(next)
		print(vertices[next])
		if(current == leftmost):
			break
	
	var triangles = []
	for i in range(hull.size() - 2):
		triangles.append([
			hull[0],
			hull[i + 1],
			hull[i + 2]
		])

	return triangles
	


var tesseract_vertices = [    
		[0, 0, 0, 0],    
		[0, 0, 0, 1],
		[0, 0, 1, 0],
		[0, 0, 1, 1],
		[0, 1, 0, 0],
		[0, 1, 0, 1],
		[0, 1, 1, 0],
		[0, 1, 1, 1],
		[1, 0, 0, 0],
		[1, 0, 0, 1],
		[1, 0, 1, 0],
		[1, 0, 1, 1],
		[1, 1, 0, 0],
		[1, 1, 0, 1],
		[1, 1, 1, 0],
		[1, 1, 1, 1]
	]
	
	
# Indica quais vértices do tesseract estão conectados em cada vértice (Ou seja, as arestas)
var tesseract_connections = [
	[01,02,04,08],		# 00 [0, 0, 0, 0],    
	[00,03,05,09],		# 01 [0, 0, 0, 1],
	[03,00,06,10],		# 02 [0, 0, 1, 0],
	[02,01,07,11],		# 03 [0, 0, 1, 1],
	[05,06,00,12],		# 04 [0, 1, 0, 0],
	[04,07,01,13],		# 05 [0, 1, 0, 1],
	[07,04,02,14],		# 06 [0, 1, 1, 0],
	[06,05,03,15],		# 07 [0, 1, 1, 1],
	[09,10,12,00],		# 08 [1, 0, 0, 0],
	[08,11,13,01],		# 09 [1, 0, 0, 1],
	[11,08,14,02],		# 10 [1, 0, 1, 0],
	[10,09,15,03],		# 11 [1, 0, 1, 1],
	[13,14,08,04],		# 12 [1, 1, 0, 0],
	[12,15,09,05],		# 13 [1, 1, 0, 1],
	[15,12,10,06],		# 14 [1, 1, 1, 0],
	[14,13,11,07]		# 15 [1, 1, 1, 1]
]


# Called when the node enters the scene tree for the first time.
func _ready():
	
	tesseract_vertices = move(tesseract_vertices,[-0.5,-0.5,-0.5,-0.5])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
	mesh.clear_surfaces()
	var mesh_arr=[]
	var mesh_vertices = PackedVector3Array()
	var mesh_indices = PackedInt32Array()
	mesh_arr.resize(Mesh.ARRAY_MAX)
	
#	var anglex = get_node("../Sliders/HSlider").value
#	var angley = get_node("../Sliders/HSlider2").value
#	var anglez = get_node("../Sliders/HSlider3").value
#	var anglew = get_node("../Sliders/HSlider4").value
#	var rotated_vertices = rotate_4d_shape(tesseract_vertices,0,anglex)
#	rotated_vertices = rotate_4d_shape(rotated_vertices,1,anglez)
#	rotated_vertices = rotate_4d_shape(rotated_vertices,2,angley)
#	rotated_vertices = rotate_4d_shape(rotated_vertices,3,anglew)
#	tesseract_vertices = rotate_4d_shape(tesseract_vertices,3,1)
#	tesseract_vertices = rotate_4d_shape(tesseract_vertices,1,0.5)
#	tesseract_vertices = rotate_4d_shape(tesseract_vertices,2,0.3)
#	tesseract_vertices = rotate_4d_shape(tesseract_vertices,0,0.2)
	
	
	var m = slice_4d_shape(tesseract_vertices, tesseract_connections, Vector4(0,1,0,0), Vector4(0,0,0,0))
	
	var mesh_colors = PackedColorArray()
	var m2 = PackedInt32Array()
	var mv3 = PackedVector3Array()
	for i in range(m.size()):
		m2.append(i)
		mv3.append(Vector3(m[i][0],m[i][1],m[i][2]))
		#mesh_colors.append(Color("CRIMSON"))
	#print(mesh_colors)
	
#	mesh_arr[Mesh.ARRAY_VERTEX]=mv3
#	mesh_arr[Mesh.ARRAY_INDEX]=m2
#	mesh_arr[Mesh.ARRAY_COLOR]=mesh_colors
	#mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,mesh_arr)
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(mv3.size()):
		var c = float(i)/mv3.size()
		st.set_color(Color(c, 0, 0,1))
		st.set_uv(Vector2(0, 0))
		st.add_vertex(mv3[i])
	st.generate_normals()
	st.generate_tangents()
	mesh = st.commit()
	
	
	var projected_vertices = project_4D_coords(tesseract_vertices)
	var tess_mesh = generate_projected_tesseract_mesh(projected_vertices,tesseract_connections)
	mesh_arr[Mesh.ARRAY_VERTEX]=tess_mesh[0]
	mesh_arr[Mesh.ARRAY_INDEX]=tess_mesh[1]
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES,mesh_arr)
	
	
#	var hullv3 = PackedVector3Array()
#	for i in range(projected_vertices.size()):
#		hullv3.append(Vector3(projected_vertices[i][0],projected_vertices[i][1],projected_vertices[i][2]))
#	var hull = compute_convex_hull(hullv3)
#	var hullidx = []
#	for i in range(hullv3.size()):
#		hullidx.append(i)
#	mesh_arr[Mesh.ARRAY_VERTEX]=hullv3
#	mesh_arr[Mesh.ARRAY_INDEX]=hullidx
#	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,mesh_arr)
	


# Rotaciona em cada eixo com as teclas ZXCV/ASDF (+ angulo / - angulo)
func _input(ev):
	if Input.is_key_pressed(KEY_Z):
		tesseract_vertices = rotate_4d_shape(tesseract_vertices,0,2)
	elif Input.is_key_pressed(KEY_A):
		tesseract_vertices = rotate_4d_shape(tesseract_vertices,0,-2)
	if Input.is_key_pressed(KEY_X):
		tesseract_vertices = rotate_4d_shape(tesseract_vertices,1,2)
	elif Input.is_key_pressed(KEY_S):
		tesseract_vertices = rotate_4d_shape(tesseract_vertices,1,-2)
	if Input.is_key_pressed(KEY_C):
		tesseract_vertices = rotate_4d_shape(tesseract_vertices,2,2)
	elif Input.is_key_pressed(KEY_D):
		tesseract_vertices = rotate_4d_shape(tesseract_vertices,2,-2)
	if Input.is_key_pressed(KEY_V):
		tesseract_vertices = rotate_4d_shape(tesseract_vertices,3,2)
	elif Input.is_key_pressed(KEY_F):
		tesseract_vertices = rotate_4d_shape(tesseract_vertices,3,-2)
		
