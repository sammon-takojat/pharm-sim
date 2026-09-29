extends GdUnitTestSuite

func test_mouse_movement(direction:Vector2, axis:String, increase:bool, _test_parameters := [
	[Vector2(0, -100), "x", true],
	[Vector2(0, 100), "x", false],
	[Vector2(-100, 0), "y", true],
	[Vector2(100, 0), "y", false]
]):
	# Create a scene
	var	runner := scene_runner("res://Scenes/World.tscn")
	var camera:Camera3D = runner.find_child("Camera3D")
	var start_dir:Vector3 = camera.global_rotation_degrees
	
	# Simulate mouse movement
	runner.simulate_mouse_move_relative(direction, 2.0)
	await await_millis(2000)

	# Camera rotates around chosen axis
	var end_dir:Vector3 = camera.global_rotation_degrees
	if axis == "x":
		if increase == true:
			assert_float(end_dir.x).is_greater(start_dir.x)
		else:
			assert_float(end_dir.x).is_less(start_dir.x)
	else:
		if increase == true:
			assert_float(end_dir.y).is_greater(start_dir.y)
		else:
			assert_float(end_dir.y).is_less(start_dir.y)
