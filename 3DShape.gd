extends MeshInstance3D
enum SHAPE {CUBE, TETRAHEDRON, SPHERE, CILINDER}

var mode = 0
var shape = {}

@export var shapeName = SHAPE.CUBE
var moved = true
var moved2D = true
var moved2Dcollision = true
var movedWireframe = true

#var move_value = [0.0,0.0,0.0]

func generate_sphere_mesh(num_segments: int, num_rings: int) -> Dictionary:
	var vertices = []
	var triangles = []
	var colors = []
	var debug_tris = []
	
	var delta_phi = PI / num_rings
	var delta_theta = 2 * PI / num_segments
	
	for i in range(num_rings + 1):
		var phi = i * delta_phi
		var sin_phi = sin(phi)
		var cos_phi = cos(phi)
		
		for j in range(num_segments + 1):
			var theta = j * delta_theta
			var sin_theta = sin(theta)
			var cos_theta = cos(theta)
			
			var x = cos_theta * sin_phi
			var y = sin_theta * sin_phi
			var z = cos_phi
#			print(x*x, " ", y*y, " ", z*z)
			
			vertices.append(Vector3(x, y, z))
			
			if i > 0 and j > 0:
				var v0 = (i - 1) * (num_segments + 1) + j - 1
				var v1 = i * (num_segments + 1) + j - 1
				var v2 = i * (num_segments + 1) + j
				var v3 = (i - 1) * (num_segments + 1) + j
				
				triangles.append([v0, v1, v2])
				triangles.append([v0, v2, v3])
				
				debug_tris.append([vertices[v0],vertices[v1],vertices[v2]])
				debug_tris.append([vertices[v0],vertices[v2],vertices[v3]])
	
	return {"vertices": vertices, "triangles": triangles, "debug_tris": debug_tris}

func generate_cilinder_mesh(num_segments: int, ext_factor) -> Dictionary:
	var vertices = []
	var triangles = []
	var colors = []
	var debug_tris = []
	
	var delta_theta = 2 * PI / num_segments
	
		
	vertices.append(Vector3(0, -ext_factor/2, 0))
	vertices.append(Vector3(0, ext_factor/2, 0))
#	colors.append(Color(0,0,0))
#	colors.append(Color(0,0,0))
	
	for i in range(num_segments + 1):
		var theta = i * delta_theta
		var sin_theta = sin(theta)
		var cos_theta = cos(theta)
			
		var x = sin_theta
		var y1 = -ext_factor/2
		var y2 = ext_factor/2
		var z = cos_theta
#			print(x*x, " ", y*y, " ", z*z)
			
		vertices.append(Vector3(x, y1, z))
		vertices.append(Vector3(x, y2, z))
			
		if i > 0:
			var v0 = 2 + (i - 1) * 2
			var v1 = 2 + i 		 * 2 
			var v2 = 2 + i 		 * 2 + 1 
			var v3 = 2 + (i - 1) * 2 + 1
				
			triangles.append([v2, v1, v0])
			triangles.append([v3, v2, v0])
			triangles.append([v0, v1, 0])
			triangles.append([v2, v3, 1])
			
		var c = Color(float(num_segments-i)/num_segments,0,float(i)/num_segments)
		for ic in range(4):
			colors.append(c)	
#			debug_tris.append([vertices[v0],vertices[v1],vertices[v2]])
#			debug_tris.append([vertices[v0],vertices[v2],vertices[v3]])
	
	return {"vertices": vertices, "triangles": triangles, "colors": colors,"debug_tris": debug_tris}


# Move os vertices do array passado em amount
func move(coords: Array, amount: Array) -> Array:
	for i in range(coords.size()):
		for j in range(3):
			coords[i][j]+=amount[j]
	return coords

# Rotaciona o Array de vertices passados em angle_degrees, no eixo axis_index no centro origin
func rotate_vertices_by_axis(vertices: Array, axis_index: int, angle_degrees: float, origin: Vector3) -> Array:
	var rotation_axis = Vector3.ZERO
	rotation_axis[axis_index] = 1.0  # set the axis to rotate around
	var rotation = Transform3D().rotated(rotation_axis, deg_to_rad(angle_degrees))
	var rotated_vertices = []
	for vertex in vertices:
		var translated_vertex = vertex - origin  # translate the vertex to the origin
		var rotated_vertex = rotation*(translated_vertex)  # rotate the translated vertex
		var final_vertex = rotated_vertex + origin  # translate the rotated vertex back to its original position
		rotated_vertices.append(final_vertex)
	return rotated_vertices

# retorna todos os arrays que definem a forma em um dicionario
# index 0 = cubo, index 1 = tetraedro
func set_shape(index):
	var vertices = []
	var tris = []
	var colors = []
	var wireframe = []
	var pos = Vector3(0,0,0)
	if index == SHAPE.CUBE:
		vertices = [    
			Vector3(0, 0, 0), #0   
			Vector3(0, 0, 1), #1
			Vector3(0, 1, 0), #2
			Vector3(0, 1, 1), #3
			Vector3(1, 0, 0), #4
			Vector3(1, 0, 1), #5
			Vector3(1, 1, 0), #6
			Vector3(1, 1, 1)  #7
		]
		wireframe = [
			[1,2,4],
			[3,5],
			[3,6],
			[7],
			[5,6],
			[7],
			[7],
			[]
		]
		tris = [
			[02,01,00], 
			[01,02,03],

			[05,04,00],
			[00,01,05],

			[04,02,00],
			[02,04,06],

			[04,05,06],
			[07,06,05],

			[07,03,02],
			[02,06,07],

			[01,03,05],
			[07,05,03]
		]
		colors = [    
#			Color(0, 0, 0),
			Color(0, 0, 1),
			Color(0, 1, 0),
			Color(0, 1, 1),
			Color(1, 0, 0),
			Color(1, 0, 1),
			Color(1, 1, 0),
#			Color(1, 1, 1)
		]
		vertices = move(vertices,[-0.5,-0.5,-0.5])
	if index == SHAPE.TETRAHEDRON:
		vertices = [    
			Vector3(-1./3, 0.0, sqrt(8./9)),    
			Vector3(-1./3, sqrt(2./3), -sqrt(2./9)),    
			Vector3(-1./3, -sqrt(2./3), -sqrt(2./9)),    
			Vector3(1.0, 0.0, 0.0)
		]
		wireframe = [
			[1,2,3], # v0
			[2,3],   # v1
			[3],     # v2
			[]       # v3
		]
		tris = [
			[0, 2, 1],
			[0, 1, 3],
			[0, 3, 2],
			[1, 2, 3],
		]
		colors = [
			# Cor de cada face
			Color(1, 1, .5),    
			Color(0, 0, 1),    
			Color(1, 0, 0),    
			Color(0, 1, 0)
		]
		vertices = move(vertices,[0,-(sqrt(2)/4),0])
	if index == SHAPE.SPHERE:
		var res = generate_sphere_mesh(10,10)
		vertices = res.vertices
		tris = res.triangles
#		print(res.debug_tris)
		for i in vertices:
			colors.append(Color(1,0,0))
	if index == SHAPE.CILINDER:
		var res = generate_cilinder_mesh(10,2)
		vertices = res.vertices
		tris = res.triangles
#		print(res.debug_tris)
		colors = res.colors
	
	return {"vertices" : vertices,"triangles": tris,"colors" :colors, "pos" : pos, "wireframe": wireframe}
		
# Called when the node enters the scene tree for the first time.
func _ready():
	shape = set_shape(shapeName)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if(moved):
		mesh.clear_surfaces()
		var mesh_arr=[]
		var mesh_vertices = PackedVector3Array()
		var mesh_indices = PackedInt32Array()
		mesh_arr.resize(Mesh.ARRAY_MAX)
		
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_uv(Vector2(0, 0))
		var i = 0
		for tri in shape.triangles:
			st.set_color(shape.colors[i/2])
			if(len(shape.colors)==len(shape.vertices) and i<len(shape.colors)):
				st.set_color(shape.colors[i])
				
			i+=1
			for v in tri:
				#st.set_color(shape.colors[v])
				st.add_vertex(shape.vertices[v])
			
		st.generate_normals()
		st.generate_tangents()
		mesh = st.commit()
		moved = false
	



# Rotaciona em cada eixo com as teclas ZXC/ASD (+ angulo / - angulo)
func _input(ev):
#	if Input.is_key_pressed(KEY_F9):
#		get_tree().change_scene_to_file("res://3dto2d.tscn")
	if ev.is_action_pressed("ui_cancel"):
		get_tree().quit() # Quits the game
	if Input.is_key_pressed(KEY_F10):
		get_tree().change_scene_to_file("res://4dto3D.tscn")
	if Input.is_key_pressed(KEY_F11):
		get_tree().change_scene_to_file("res://Levels/Main/L_Main.tscn")
	if mode==0:
		if Input.is_key_pressed(KEY_Z) and !(ev.is_command_or_control_pressed()):
			shape.vertices = rotate_vertices_by_axis(shape.vertices,0,2,shape.pos)
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true
		elif Input.is_key_pressed(KEY_A) and !(ev.is_command_or_control_pressed()):
			shape.vertices = rotate_vertices_by_axis(shape.vertices,0,-2,shape.pos)
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true
		if Input.is_key_pressed(KEY_X) and !(ev.is_command_or_control_pressed()):
			shape.vertices = rotate_vertices_by_axis(shape.vertices,1,2,shape.pos)
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true
		elif Input.is_key_pressed(KEY_S) and !(ev.is_command_or_control_pressed()):
			shape.vertices = rotate_vertices_by_axis(shape.vertices,1,-2,shape.pos)
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true
		if Input.is_key_pressed(KEY_C) and !(ev.is_command_or_control_pressed()) :
			shape.vertices = rotate_vertices_by_axis(shape.vertices,2,2,shape.pos)
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true
		elif Input.is_key_pressed(KEY_D) and !(ev.is_command_or_control_pressed()):
			shape.vertices = rotate_vertices_by_axis(shape.vertices,2,-2,shape.pos)
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true

		if Input.is_key_pressed(KEY_G) and !(ev.is_command_or_control_pressed()):
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true
			shape.pos[1] += 0.04
			shape.vertices = move(shape.vertices,[0,0.04,0])
		elif Input.is_key_pressed(KEY_B) and !(ev.is_command_or_control_pressed()):
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true
			shape.pos[1] -= 0.04
			shape.vertices = move(shape.vertices,[0,-0.04,0])
		elif Input.is_key_pressed(KEY_1):
			shape = set_shape(SHAPE.CUBE)
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true
		elif Input.is_key_pressed(KEY_2):
			shape = set_shape(SHAPE.TETRAHEDRON)
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true
		elif Input.is_key_pressed(KEY_3):
			shape = set_shape(SHAPE.SPHERE)
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true
		elif Input.is_key_pressed(KEY_4):
			shape = set_shape(SHAPE.CILINDER)
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true
		
	if mode==1:
		if Input.is_key_pressed(KEY_A):
			shape.vertices = rotate_vertices_by_axis(shape.vertices,0,3,shape.pos)
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true
		elif Input.is_key_pressed(KEY_D):
			shape.vertices = rotate_vertices_by_axis(shape.vertices,0,-3,shape.pos)
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true


		if Input.is_key_pressed(KEY_W):
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true
			shape.pos[1] += 0.04
			shape.vertices = move(shape.vertices,[0,0.04,0])
		elif Input.is_key_pressed(KEY_S):
			moved = true
			moved2D = true
			moved2Dcollision = true
			movedWireframe = true
			shape.pos[1] -= 0.04
			shape.vertices = move(shape.vertices,[0,-0.04,0])
