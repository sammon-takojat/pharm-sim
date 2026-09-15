extends GdUnitTestSuite

var runner:GdUnitSceneRunner
var player:CharacterBody3D
var camera:Camera3D
var start_dir:Vector3

func before_test():
	# Create a scene
	runner = scene_runner("res://Scenes/World.tscn")
	player = runner.find_child("Player")
	camera = player.find_child("Camera3D")
	start_dir = camera.global_rotation_degrees

func test_mouse_up():
	# Simulate mouse moving up
	runner.simulate_mouse_move_relative(Vector2(0, -100), 2.0)
	await await_millis(2000)

	# Camera rotates upwards around x axis
	var end_dir:Vector3 = camera.global_rotation_degrees
	assert_float(end_dir.x).is_greater(start_dir.x)

func test_mouse_down():
	# Simulate mouse moving down
	runner.simulate_mouse_move_relative(Vector2(0, 100), 2.0)
	await await_millis(2000)

	# Camera rotates down around x axis
	var end_dir:Vector3 = camera.global_rotation_degrees
	assert_float(end_dir.x).is_less(start_dir.x)

func test_mouse_left():
	# Simulate mouse moving left
	runner.simulate_mouse_move_relative(Vector2(-100, 0), 2.0)
	await await_millis(2000)

	# Camera rotates left around y axis
	var end_dir:Vector3 = camera.global_rotation_degrees
	assert_float(end_dir.y).is_greater(start_dir.y)

func test_mouse_right():
	# Simulate mouse moving right
	runner.simulate_mouse_move_relative(Vector2(100, 0), 2.0)
	await await_millis(2000)

	# Camera rotates right around y axis
	var end_dir:Vector3 = camera.global_rotation_degrees
	assert_float(end_dir.y).is_less(start_dir.y)
