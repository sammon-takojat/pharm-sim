extends GdUnitTestSuite

var runner:GdUnitSceneRunner
var player_head:Node3D
var cube:RigidBody3D

func before_test():
	#var scene:Node3D = auto_free(Node3D.new())
	#scene.add_child(WorldEnvironment.new())
	
	var cube_init:RigidBody3D = auto_free(RigidBody3D.new())
	cube_init.name = "Cube"
	var coll:CollisionShape3D = auto_free(CollisionShape3D.new())
	coll.shape = BoxShape3D.new()
	cube_init.add_child(coll)
	var mesh:MeshInstance3D = auto_free(MeshInstance3D.new())
	mesh.mesh = BoxMesh.new()
	cube_init.add_child(mesh)
	
	
	var scene = auto_free(load("res://Test/TestScenes/TestScene.tscn").instantiate())
	scene.add_child(cube_init)
	cube_init.transform.origin = Vector3(2, 0.5, 0)
	cube_init.add_to_group("pickable")
	
	#var player_inst = auto_free(load("res://Scenes/Player.tscn").instantiate())
	#scene.add_child(player_inst)
	#player_inst.transform.origin = Vector3(0, 0, 0)
	
	runner = scene_runner(scene)
	
	player_head = runner.find_child("Player").find_child("Head")
	cube = runner.find_child("Cube")

func test_pick_up_object():
	await await_millis(500)
	player_head.look_at(cube.global_position)
	await await_idle_frame()
	runner.simulate_key_pressed(KEY_E)
	await await_millis(500)
	assert_that(player_head.held_object).is_equal(cube)

func test_set_down_object():
	player_head.held_object = cube
	runner.simulate_key_pressed(KEY_E)
	await await_millis(500)
	assert_that(player_head.held_object).is_equal(null)

func test_move_object_up():
	player_head.held_object = cube
	runner.simulate_mouse_move_relative(Vector2(0, -100))
	await await_millis(500)
	assert_that(cube.global_position.y).is_greater(1)

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
