extends GdUnitTestSuite
## Script for testing camera movement with mouse inputs.

## The function tests that the camera moves to the correct direction when mouse movement
## is simulated to each direction.
func test_mouse_movement(direction:Vector2, axis:String, increase:bool, _test_parameters := [
	[Vector2(0, -100), "x", true],
	[Vector2(0, 100), "x", false],
	[Vector2(-100, 0), "y", true],
	[Vector2(100, 0), "y", false]
]):
	## Create a scene
	var	runner := scene_runner("res://Test/TestScenes/TestScene.tscn")
	var camera:Camera3D = runner.find_child("Camera3D")
	
	## The direction that the player is facing in the beginning of the test
	var start_dir:Vector3 = camera.global_rotation_degrees
	
	## Simulate mouse movement
	runner.simulate_mouse_move_relative(direction, 2.0)
	await await_millis(2000)

	## The direction that the player is facing after input simulation
	var end_dir:Vector3 = camera.global_rotation_degrees
	
	## Check that the input lead to the correct change in camera rotation.
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
