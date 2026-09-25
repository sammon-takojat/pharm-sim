extends GdUnitTestSuite

func before_test():
	var scene:Node3D = auto_free(Node3D.new())
	scene.add_child(WorldEnvironment.new())
	
	var cube:RigidBody3D = auto_free(RigidBody3D.new())
	cube.name = "Cube"
	var coll:CollisionShape3D = auto_free(CollisionShape3D.new())
	coll.shape = BoxShape3D.new()
	cube.add_child(coll)
	var mesh:MeshInstance3D = auto_free(MeshInstance3D.new())
	mesh.mesh = BoxMesh.new()
	cube.add_child(mesh)
	scene.add_child(cube)
	cube.transform.origin = Vector3(0, 1, 0)
	cube.add_to_group("pickable")
	
	var player = auto_free(load("res://Scenes/Player.tscn").instantiate())
	scene.add_child(player)
	player.transform.origin = Vector3(0, 0, 0)
	
	var runner := scene_runner(scene)

func test_pick_up_object():
	pass

func test_set_down_object():
	pass

func test_move_object_up():
	pass

func test_move_object_down():
	pass

func test_move_object_left():
	pass

func test_move_object_right():
	pass

func test_move_object_forward():
	pass

func test_move_object_back():
	pass
