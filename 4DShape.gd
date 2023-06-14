extends Node
enum {SELF, SHARED}
enum {CUBE, TETRAHEDRON, TESSERACT, HYPERSPHERE, BRIDGE, PENTACHORON, ICOSITETRACHORON, LONG_SPHERE, TEAPOT}
var shape = {}
var shape4DNode 
var move_value = [0.0,0.0,0.0,0.0]
var mode = SELF
var shapeList
var pend
var elapsed = 0
var changedShape = false

func generate_glome_mesh(num_segments: int, num_rings: int, num_columns: int) -> Dictionary:
	var vertices = []
	var tetrahedrons = []
	var wireframe = []
	var colors = []
	
	var delta_phi = 2 * PI / num_rings
	var delta_theta = 1 * PI / num_segments
	var delta_psi =   1 * PI / num_columns
	
	for i in range(num_rings + 1):
		var phi = i * delta_phi
		var sin_phi = sin(phi)
		var cos_phi = cos(phi)
		
		for j in range(num_segments + 1):
			var theta = j * delta_theta
			var sin_theta = sin(theta)
			var cos_theta = cos(theta)
			
			for k in range(num_columns + 1):
				var psi = k * delta_psi
				var sin_psi = sin(psi)
				var cos_psi = cos(psi)
				
				var x = sin_psi * sin_phi * sin_theta
				var y = sin_psi * sin_theta * cos_phi
				var z = sin_psi * cos_theta
				var w = cos_psi
				#print(x*x + y*y + z*z + w*w)

				vertices.append(Vector4(x, y, z, w))
#				print("AAAA: ",i," ",j," ",k)
				var elem = [
					((num_segments+1)*(num_columns+1)*i)					+((num_columns+1)*j)						+((k+1)%(num_columns+1)),
					((num_segments+1)*(num_columns+1)*i)					+((num_columns+1)*((j+1)%(num_segments+1)))	+k,
					((num_segments+1)*(num_columns+1)*((i+1)%(num_rings+1)))+((num_columns+1)*j)						+k
				]
#				print("BBBB: ", elem)
				wireframe.append(elem)
				
				if i > 0 and j > 0 and k > 0:
					
					var v0 = (i - 1) * (num_segments + 1) * (num_columns + 1) + (j - 0) * (num_columns + 1) + (k - 0)
					var v1 = (i - 1) * (num_segments + 1) * (num_columns + 1) + (j - 0) * (num_columns + 1) + (k - 1)
					var v2 = (i - 1) * (num_segments + 1) * (num_columns + 1) + (j - 1) * (num_columns + 1) + (k - 0)
					var v3 = (i - 1) * (num_segments + 1) * (num_columns + 1) + (j - 1) * (num_columns + 1) + (k - 1)

					var v4 = (i - 0) * (num_segments + 1) * (num_columns + 1) + (j - 0) * (num_columns + 1) + (k - 0)
					var v5 = (i - 0) * (num_segments + 1) * (num_columns + 1) + (j - 0) * (num_columns + 1) + (k - 1)
					var v6 = (i - 0) * (num_segments + 1) * (num_columns + 1) + (j - 1) * (num_columns + 1) + (k - 0)
					var v7 = (i - 0) * (num_segments + 1) * (num_columns + 1) + (j - 1) * (num_columns + 1) + (k - 1)
				
#					print("AAA: ", vertices.size())
#					print("BBB: ", v4)
							
					tetrahedrons.append([v0,v1,v2,v4])
					tetrahedrons.append([v1,v4,v5,v7])
					tetrahedrons.append([v2,v4,v7,v6])
					tetrahedrons.append([v1,v2,v3,v7])
					tetrahedrons.append([v1,v2,v4,v7])
	
					var c = Color(float(i)/num_rings,float(j)/num_segments,float(k)/num_columns)
					for ic in range(5):
						colors.append(c)
#					triangles.append([v0, v1, v2, v4])
#					triangles.append([v0, v1, v4, v5])
#					triangles.append([v0, v4, v5, v6])

					

	
	return {"vertices": vertices, "tetras": tetrahedrons, "wireframe" : wireframe, "colors" : colors}

# Move os vertices do array passado em amount
func move(coords: Array, amount: Array) -> Array:
	for i in range(coords.size()):
		for j in range(4):
			coords[i][j]+=amount[j]
	return coords

# LEMBRAR DE ADICIONAR ORIGIN
func rotate_4d_coord(coord: Vector4, axis: int, angle_degrees: float):
	
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
			sum += rotation_matrix[i][j] * coord[j]
		new_coord[i] = sum
			
	
#    var new_coord = [        sum(rotation_matrix[i][j] * coord[j] for j in range(4))
#        for i in range(4)
#    ]
	
	return Vector4(new_coord[0],new_coord[1],new_coord[2],new_coord[3])

# Rotaciona todas as coordenadas de uma forma
func rotate_4d_shape(coords: Array, axis_idx: int, angle_degrees: float,origin):
	var result = []
	for i in range(coords.size()):
#		var translated_vertex = vertex - origin  # translate the vertex to the origin
#		var rotated_vertex = rotation*(translated_vertex)  # rotate the translated vertex
#		var final_vertex = rotated_vertex + origin  # translate the rotated vertex back to its original position
		
		var v4 = Vector4(coords[i][0],coords[i][1],coords[i][2],coords[i][3])
		var translated_vertex = v4 - origin  # translate the vertex to the origin
		var rotated_vertex = rotate_4d_coord(translated_vertex,axis_idx,angle_degrees)  # rotate the translated vertex
		var final_vertex = rotated_vertex + origin  # translate the rotated vertex back to its original position
		
		result.append(final_vertex)

	return result
	
func triangles_share_edge(tri_i: Array, tri_j: Array):
	for i in range(3):
		for j in range(3):
			if tri_i[i] == tri_j[j] and tri_i[(i+1)%3] == tri_j[(j+1)%3]:
				return [true,(i+2)%3]
			if tri_i[i] == tri_j[(j+1)%3] and tri_i[(i+1)%3] == tri_j[j]:
				return [true,(i+2)%3]
	return [false,0]

# retorna todos os arrays que definem a forma em um dicionario
# index 0 = cubo, index 1 = tetraedro
func set_shape(index):
	var vertices = []
	var tetras = []
	var colors = []
	var wireframe = []
	var simplexcolors = []
	var pos = Vector4(0,0,0,0)
	if index == CUBE:
		vertices = [    
			Vector4(0, 0, 0, 0),   
			Vector4(0, 0, 1, 0),
			Vector4(0, 1, 0, 0),
			Vector4(0, 1, 1, 0),
			Vector4(1, 0, 0, 0),
			Vector4(1, 0, 1, 0),
			Vector4(1, 1, 0, 0),
			Vector4(1, 1, 1, 0)
		]
#		tetras = [
#			[00,01,02,05], 
#			[02,05,06,07],
#			[00,04,05,07],
#			[00,02,05,07],
#			[00,02,03,07]
#		]
		tetras = [
			[0,1,2,4],
			[1,4,5,7],
			[2,4,7,6],
			[1,2,3,7],
			[1,2,4,7]
		]
		simplexcolors = [
			Color(0,0,0),
			Color(1,0,0),
			Color(0,1,0),
			Color(0,0,1),
			Color(1,1,1)
		]
		colors = [    
			Color(0, 0, 0),   
			Color(0, 0, 1),
			Color(0, 1, 0),
			Color(0, 1, 1),
			Color(1, 0, 0),
			Color(1, 0, 1),
			Color(1, 1, 0),
			Color(1, 1, 1)
		]
		
		vertices = move(vertices,[-0.5,-0.5,-0.5,0.0])
	if index == TETRAHEDRON:
		vertices = [    
			Vector4(-0.5, 0.0, -0.29,0),    
			Vector4(0.5, 0.0, -0.29,0),    
			Vector4(0.0, 0.0, 0.58,0),    
			Vector4(0.0, 1.0, 0.0,0)
		]
		tetras = [
			[00, 01, 02, 03]
		]
		colors = [    
			Color(1, 1, 1),    
			Color(0, 0, 1),    
			Color(1, 0, 0),    
			Color(0, 1, 0)
		]
		simplexcolors = [
			Color(1,0,0)
		]
		vertices = move(vertices,[0,-(sqrt(2)/4),0,0])
	if index == TESSERACT:
		vertices = [    
			Vector4(0, 0, 0, 0),    
			Vector4(0, 0, 0, 1),
			Vector4(0, 0, 1, 0),
			Vector4(0, 0, 1, 1),
			Vector4(0, 1, 0, 0),
			Vector4(0, 1, 0, 1),
			Vector4(0, 1, 1, 0),
			Vector4(0, 1, 1, 1),
			Vector4(1, 0, 0, 0),
			Vector4(1, 0, 0, 1),
			Vector4(1, 0, 1, 0),
			Vector4(1, 0, 1, 1),
			Vector4(1, 1, 0, 0),
			Vector4(1, 1, 0, 1),
			Vector4(1, 1, 1, 0),
			Vector4(1, 1, 1, 1)
		]
		var cells = []
		cells.append([0,1,2,3,4,5,6,7])
		cells.append([8,9,10,11,0,1,2,3])
		cells.append([8,9,0,1,12,13,4,5])
		cells.append([2,3,10,11,6,7,14,15])
		cells.append([4,5,6,7,12,13,14,15])
		cells.append([8,0,10,2,12,4,14,6])
		cells.append([1,9,3,11,5,13,7,15])
		cells.append([8,9,10,11,12,13,14,15])
		
		var cellcolors = [
			Color(0,0,0),
			Color(0,0,1),
			Color(0,1,0),
			Color(0,1,1),
			Color(1,0,0),
			Color(1,0,1),
			Color(1,1,0),
			Color(1,1,1)
		]
		
		wireframe = [
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
		
#		for vertex in vertices:
#			colors.append(cmyk_to_rgb(vertex))
		
		vertices = move(vertices,[-0.5,-0.5,-0.5,-0.5])
		tetras = []
		for i in range(cells.size()):
			var cell = cells[i]
			for j in range(5):
				simplexcolors.append(cellcolors[i])
			tetras.append([cell[0],cell[1],cell[2],cell[4]])
			tetras.append([cell[1],cell[4],cell[5],cell[7]])
			tetras.append([cell[2],cell[4],cell[7],cell[6]])
			tetras.append([cell[1],cell[2],cell[3],cell[7]])
			tetras.append([cell[1],cell[2],cell[4],cell[7]])
		colors = [
			Color(0.0,0.0,0.0,0.9),
			Color(0.0,0.0,0.0,0.9),
			Color(0.0,0.0,1.0,0.9),
			Color(0.0,0.0,0.4,0.9),
			Color(0.0,1.0,0.0,0.9),
			Color(0.0,0.4,0.0,0.9),
			Color(0.0,1.0,1.0,0.9),
			Color(0.4,0.0,0.4,0.9),
			Color(0.0,0.4,0.4,0.9),
			Color(1.0,0.0,0.0,0.9),
			Color(0.4,0.0,0.0,0.9),
			Color(1.0,0.0,1.0,0.9),
			Color(1.0,1.0,0.0,0.9),
			Color(0.4,0.4,0.0,0.9),
			Color(1.0,1.0,1.0,0.9),
			Color(0.4,0.4,0.4,0.9)
		]	
#	if index == FIVECELL:
#		vertices = [
#			Vector4(1,0,0,0),
#			Vector4(-1/4,sqrt(5/2),sqrt(5/2),sqrt(5/2)),
#			Vector4(-1/4,-sqrt(5/2),-sqrt(5/2),sqrt(5/2)),
#			Vector4(-1/4,-sqrt(5/2),sqrt(5/2),-sqrt(5/2)),
#			Vector4(-1/4,sqrt(5/2),-sqrt(5/2),-sqrt(5/2))
#		]
#		tetras = [
#			[0, 1, 2, 3],
#			[0, 1, 2, 4],
#			[0, 1, 3, 4],
#			[0, 2, 3, 4],
#			[1, 2, 3, 4]
#		]
#		simplexcolors = [
#			Color(0,0,0),
#			Color(1,0,0),
#			Color(0,1,0),
#			Color(0,0,1),
#			Color(1,1,1)
#		]
#		colors = [
#			Color(0,0,0,0.9),
#			Color(1,0,0,0.9),
#			Color(0,1,0,0.9),
#			Color(0,0,1,0.9),
#			Color(1,1,1,0.9)
#		]
#
	if index == HYPERSPHERE:
		var res = generate_glome_mesh(10,10,10)
		vertices = res.vertices
		tetras = res.tetras
		wireframe = res.wireframe
		simplexcolors = res.colors
	
	if index == BRIDGE:
		vertices = [    
			Vector4(0, 0, 0, -2),    
									Vector4(4, 0, 0, 2),
			Vector4(0, 0, 1, -2),
									Vector4(4, 0, 1, 2),
			Vector4(0, 1, 0, -2),
									Vector4(4, 1, 0, 2),
			Vector4(0, 1, 1, -2),
									Vector4(4, 1, 1, 2),
			Vector4(0.2, 0, 0, -2),
									Vector4(5, 0, 0, 2),
			Vector4(0.2, 0, 1, -2),
									Vector4(5, 0, 1, 2),
			Vector4(0.2, 1, 0, -2),
									Vector4(5, 1, 0, 2),
			Vector4(0.2, 1, 1, -2),
									Vector4(5, 1, 1, 2)
		]

		var cells = []
		cells.append([0,1,2,3,4,5,6,7])
		cells.append([8,9,10,11,0,1,2,3])
		cells.append([8,9,0,1,12,13,4,5])
		cells.append([2,3,10,11,6,7,14,15])
		cells.append([4,5,6,7,12,13,14,15])
		cells.append([8,0,10,2,12,4,14,6])
		cells.append([1,9,3,11,5,13,7,15])
		cells.append([8,9,10,11,12,13,14,15])
		
		var cellcolors = [
			Color(0,0,0),
			Color(0,0,1),
			Color(0,1,0),
			Color(0,1,1),
			Color(1,0,0),
			Color(1,0,1),
			Color(1,1,0),
			Color(1,1,1)
		]
		
		wireframe = [
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
		
#		for vertex in vertices:
#			colors.append(cmyk_to_rgb(vertex))
		
		vertices = move(vertices,[-0.5,-0.5,-0.5,0.0])
		tetras = []
		for i in range(cells.size()):
			var cell = cells[i]
			for j in range(5):
				simplexcolors.append(cellcolors[i])
			tetras.append([cell[0],cell[1],cell[2],cell[4]])
			tetras.append([cell[1],cell[4],cell[5],cell[7]])
			tetras.append([cell[2],cell[4],cell[7],cell[6]])
			tetras.append([cell[1],cell[2],cell[3],cell[7]])
			tetras.append([cell[1],cell[2],cell[4],cell[7]])	
	if index == ICOSITETRACHORON or index == PENTACHORON:
		var shapeName
		if(index==ICOSITETRACHORON):
			shapeName = "Icositetrachoron"
		elif(index==PENTACHORON):
			shapeName = "Pentachoron"
#		shapeName = "Tesseract"
#		shapeName = "Hecatonicosachoron"
#		shapeName = "Truncated pentachoron"
#		shapeName = "Rectified tesseract"
#		shapeName = "Great stellated hecatonicosachoron"
		var shapeDict = shapeList.dict
	
		vertices = shapeDict[shapeName].vertices
		var faces = shapeDict[shapeName].faces
		var cells = shapeDict[shapeName].cells
		
		var colorPool = [
			Color(0,0,0),
			Color(0,0,1),
			Color(0,1,0),
			Color(0,1,1),
			Color(1,0,0),
			Color(1,0,1),
			Color(1,1,0),
			Color(1,1,1),
			
			Color(0,0,0.25),
			Color(0,0.25,0),
			Color(0,0.25,0.25),
			Color(0.25,0,0),
			Color(0.25,0,0.25),
			Color(0.25,0.25,0),
			Color(0.25,0.25,0.25),
			
			
			Color(0,0,0.5),
			Color(0,0.5,0),
			Color(0,0.5,0.5),
			Color(0.5,0,0),
			Color(0.5,0,0.5),
			Color(0.5,0.5,0),
			Color(0.5,0.5,0.5),
			
			Color(0,0,0.75),
			Color(0,0.75,0),
			Color(0,0.75,0.75),
			Color(0.75,0,0),
			Color(0.75,0,0.75),
			Color(0.75,0.75,0),
			Color(0.75,0.75,0.75)
		]	
		
		var facesTris = []
		for face in faces:
			var tris = []
			for i in range(1,face.size()-1):
				tris.append([face[0],face[i],face[i+1]])
			facesTris.append(tris)
		var x = 0
		for cell in cells:
			var curColor = colorPool[x%colorPool.size()]
			x = x+1
#			var curColor = Color((randi()%100)/100.0,(randi()%100)/100.0,(randi()%100)/100.0)
			for i in range(cell.size()-1):
				var curFace = facesTris[cell[i]]
				for j in range(i,cell.size()):
					var nxtFace = facesTris[cell[j]]
					for tri_i in curFace:
						for tri_j in nxtFace:
							var shareEdges = triangles_share_edge(tri_i,tri_j)
							if(shareEdges[0]):
								tetras.append([tri_j[0],tri_j[1],tri_j[2],tri_i[shareEdges[1]]])
								simplexcolors.append(curColor)
	if index == LONG_SPHERE or index == TEAPOT:
		var shapeDict = shapeList.tris_dict
		var tris = []
		if index == LONG_SPHERE:
			tris = shapeDict["Long Sphere"].tris
		if index == TEAPOT:
			tris = shapeDict["Teapot"].tris
#		print(tris.size())
#		print(tris[299])
		var ext_factor = 2
		var total = 0
		for tri in tris:
			var curColorint = Color((randi()%100)/100.0,(randi()%100)/100.0,(randi()%100)/100.0)
			
			for v in tri:
				vertices.append(Vector4(v[0],v[1],v[2],-ext_factor/2))
			for v in tri:
				vertices.append(Vector4(v[0],v[1],v[2],ext_factor/2))
			
			var centroid = Vector4(	(tri[0][0]+tri[1][0]+tri[2][0])/3,
									(tri[0][1]+tri[1][1]+tri[2][1])/3,
									(tri[0][2]+tri[1][2]+tri[2][2])/3,
									0)
			var c1 = Vector4(	(tri[0][0]+tri[1][0])/2,
								(tri[0][1]+tri[1][1])/2,
								(tri[0][2]+tri[1][2])/2,
								0)
			var c2 = Vector4(	(tri[0][0]+tri[2][0])/2,
								(tri[0][1]+tri[2][1])/2,
								(tri[0][2]+tri[2][2])/2,
								0)
			var c3 = Vector4(	(tri[2][0]+tri[1][0])/2,
								(tri[2][1]+tri[1][1])/2,
								(tri[2][2]+tri[1][2])/2,
								0)
			vertices.append(centroid)
			vertices.append(c1)
			vertices.append(c2)
			vertices.append(c3)
			
			vertices.append([0,0,0,-ext_factor/2])
			vertices.append([0,0,0,ext_factor/2])
			
			tetras.append([0+total,1+total,2+total,6+total])
			tetras.append([3+total,4+total,5+total,6+total])
			
			tetras.append([6+total,7+total,0+total,1+total])
			tetras.append([6+total,7+total,3+total,4+total])
			tetras.append([6+total,7+total,0+total,3+total])
			tetras.append([6+total,7+total,1+total,4+total])
			
			tetras.append([6+total,8+total,0+total,2+total])
			tetras.append([6+total,8+total,3+total,5+total])
			tetras.append([6+total,8+total,0+total,3+total])
			tetras.append([6+total,8+total,2+total,5+total])
			
			tetras.append([6+total,9+total,2+total,1+total])
			tetras.append([6+total,9+total,5+total,4+total])
			tetras.append([6+total,9+total,2+total,5+total])
			tetras.append([6+total,9+total,1+total,4+total])
			
			
			# Transforma as "pontas" em formas 4D convexas
			tetras.append([0+total,1+total,2+total,10+total])
			tetras.append([3+total,4+total,5+total,11+total])
			
			
			total += 12
			for i in range(16):
				simplexcolors.append(Color((tri[0][0]+tri[1][0]+tri[2][0])/3,
									(tri[0][1]+tri[1][1]+tri[2][1])/3,
									(tri[0][2]+tri[1][2]+tri[2][2])/3))
			
	return {"vertices" : vertices,"triangles": tetras,"colors" :colors, "pos" : pos, "simplexColors" : simplexcolors, "wireframe" : wireframe}
		
# Called when the node enters the scene tree for the first time.
func _ready():
#	shape = set_shape(CUBE)
#	shape = set_shape(TETRAHEDRON)
	#shape = set_shape(TESSERACT)
#	shape = set_shape(FIVECELL)
#	shape = set_shape(HYPERSPHERE)

	shape4DNode = get_node("../..")
	shapeList = get_node("../../ListOfShapes")
	shape = set_shape(shape4DNode.shape)
	mode = shape4DNode.shape_mode
	pend = shape4DNode.pendulum
#	if(pend.yes):
#		shape.vertices = rotate_4d_shape(shape.vertices,2,90,shape.pos)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(mode==SHARED):
		
		var factorR = 15.0
		var factorM = 15.0
		var rx = shape4DNode.rot[0]/factorR
		var ry = shape4DNode.rot[1]/factorR
		var rz = shape4DNode.rot[2]/factorR
		var rw = shape4DNode.rot[3]/factorR
		var move = [shape4DNode.move[0]/factorM,shape4DNode.move[1]/factorM,shape4DNode.move[2]/factorM,shape4DNode.move[3]/factorM]
		if(rx!=0):
			shape.vertices = rotate_4d_shape(shape.vertices,0,rx,shape.pos)
		if(ry!=0):
			shape.vertices = rotate_4d_shape(shape.vertices,1,ry,shape.pos)
		if(rz!=0):
			shape.vertices = rotate_4d_shape(shape.vertices,2,rz,shape.pos)
		if(rw!=0):
			shape.vertices = rotate_4d_shape(shape.vertices,3,rw,shape.pos)
		if(move!=[0,0,0,0]):
			shape.pos[0] += move[0]
			shape.pos[1] += move[1]
			shape.pos[2] += move[2]
			shape.pos[3] += move[3]
			shape.vertices = move(shape.vertices,move)
	if(pend.yes):
		elapsed+=1*pend.cyclespeed%360
		var r = pend.speed * cos(deg_to_rad(elapsed))
		var rd = Vector4(shape.pos[0],shape.pos[1],shape.pos[2],shape.pos[3])
		rd[(pend.axis+1)%4]+=pend.distance
		shape.vertices = rotate_4d_shape(shape.vertices,pend.axis,r,rd)
# Rotaciona em cada eixo com as teclas ZXC/ASD (+ angulo / - angulo)
func _input(ev):
	if Input.is_key_pressed(KEY_F1):
		shape = set_shape(shape4DNode.shape)
	if(mode==SELF):
		if Input.is_key_pressed(KEY_Z) and !(ev.is_command_or_control_pressed()):
			shape.vertices = rotate_4d_shape(shape.vertices,0,2,shape.pos)
		elif Input.is_key_pressed(KEY_A) and !(ev.is_command_or_control_pressed()):
			shape.vertices = rotate_4d_shape(shape.vertices,0,-2,shape.pos)
		if Input.is_key_pressed(KEY_X) and !(ev.is_command_or_control_pressed()):
			shape.vertices = rotate_4d_shape(shape.vertices,1,2,shape.pos)
		elif Input.is_key_pressed(KEY_S) and !(ev.is_command_or_control_pressed()):
			shape.vertices = rotate_4d_shape(shape.vertices,1,-2,shape.pos)
		if Input.is_key_pressed(KEY_C) and !(ev.is_command_or_control_pressed()) :
			shape.vertices = rotate_4d_shape(shape.vertices,2,2,shape.pos)
		elif Input.is_key_pressed(KEY_D) and !(ev.is_command_or_control_pressed()):
			shape.vertices = rotate_4d_shape(shape.vertices,2,-2,shape.pos)

		if Input.is_key_pressed(KEY_F) and !(ev.is_command_or_control_pressed()) :
			shape.vertices = rotate_4d_shape(shape.vertices,3,2,shape.pos)
		elif Input.is_key_pressed(KEY_V) and !(ev.is_command_or_control_pressed()):
			shape.vertices = rotate_4d_shape(shape.vertices,3,-2,shape.pos)
			
		if Input.is_key_pressed(KEY_G) and !(ev.is_command_or_control_pressed()):
			shape.pos[3] += 0.05
			shape.vertices = move(shape.vertices,[0,0,0,0.05])
		elif Input.is_key_pressed(KEY_B) and !(ev.is_command_or_control_pressed()):
			shape.pos[3] -= 0.05
			shape.vertices = move(shape.vertices,[0,0,0,-0.05])
		
		if Input.is_key_pressed(KEY_1):
			shape = set_shape(TESSERACT)
			changedShape = true
		if Input.is_key_pressed(KEY_2):
			shape = set_shape(HYPERSPHERE)
			changedShape = true
		if Input.is_key_pressed(KEY_3):
			shape = set_shape(PENTACHORON)
			changedShape = true
		if Input.is_key_pressed(KEY_4):
			shape = set_shape(ICOSITETRACHORON)
			changedShape = true
		if Input.is_key_pressed(KEY_5):
			shape = set_shape(LONG_SPHERE)
			changedShape = true
		if Input.is_key_pressed(KEY_6):
			shape = set_shape(TEAPOT)
			changedShape = true

