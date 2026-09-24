extends GdUnitTestSuite

func before_test():
	var scene := Node3D.new()
	scene.add_child(WorldEnvironment.new())
	var pickable := RigidBody3D.new()
	scene.add_child(pickable)
	pickable.add_to_group("pickable")
	var head := Node3D.new()
	head.set_script("res://Scripts/head.gd")
	
	var runner := scene_runner(scene)

func test_move_object_up():
	
	
func test_move_object_down():
	
func test_move_object_left():
	
func test_move_object_right():
