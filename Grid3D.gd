extends Node
var packedScene = preload("res://3d_cube.tscn")

func build_grid(node_to_instance: PackedScene, rows: int, columns: int, segments: int, size: Vector3):
	var sizeX = rows    *size[0]
	var sizeY = columns *size[1]
	var sizeZ = segments*size[2]
	var m = create_maze_Matrix(rows,columns,segments)
	for row in range(rows):
		for column in range(columns):
			for segment in range(segments):
				if(m[row][column][segment]==1):
					var cubo = node_to_instance.instantiate()
					self.add_child(cubo)
					var x = (-sizeX/2)+row    *size[0]+size[0]/2
					var y = (-sizeY/2)+column *size[1]+size[1]/2
					var z = (-sizeZ/2)+segment*size[2]+size[2]/2
					cubo.get_child(0).shape.pos = Vector3(0,0,0)
					cubo.get_child(0).shape.vertices = cubo.get_child(0).move(cubo.get_child(0).shape.vertices,[-x,-y,-z])

func create_maze_Matrix(a,b,c):
	var res = []
	for i in range(a):
		res.append([])
		for j in range(b):
			res[i].append([])
			for k in range(c):
				if ((i == 0 or k==0 or i == a-1 or k == c-1)) or ((i == 0 or j==0 or i == a-1 or j == b-1)) or ((k == 0 or j==0 or k == c-1 or j == b-1)):
					res[i][j].append(1)
				else:
					res[i][j].append(0)
	return res
	

# Called when the node enters the scene tree for the first time.
func _ready():
	build_grid(packedScene,9,9,9,Vector3(1,1,1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
