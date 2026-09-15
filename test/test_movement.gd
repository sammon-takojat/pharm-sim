extends GdUnitTestSuite

var runner:GdUnitSceneRunner
var player:CharacterBody3D
var start_position:Vector3

func before_test():
	# Create a scene
	runner = scene_runner("res://Scenes/World.tscn")
	player = runner.find_child("Player")
	start_position = player.global_position

func test_move_right():
	# Simulate input for key D
	runner.simulate_key_press(KEY_D)
	await await_millis(1500)
	runner.simulate_key_release(KEY_D)

	# Player moves to the right
	var end_position:Vector3 = player.global_position
	
	var movement_direction:Vector3 = start_position.direction_to(end_position)
	assert_vector(movement_direction).is_equal_approx(Vector3.RIGHT, Vector3(0.01, 0.1, 0.01))

func test_move_left():
	# Simulate input for key A
	runner.simulate_key_press(KEY_A)
	await await_millis(1500)
	runner.simulate_key_release(KEY_A)

	# Player moves to the left
	var end_position:Vector3 = player.global_position
	
	var movement_direction:Vector3 = start_position.direction_to(end_position)
	assert_vector(movement_direction).is_equal_approx(Vector3.LEFT, Vector3(0.01, 0.1, 0.01))

func test_move_fwd():
	# Simulate input for key W
	runner.simulate_key_press(KEY_W)
	await await_millis(1500)
	runner.simulate_key_release(KEY_W)

	# Player moves forward
	var end_position:Vector3 = player.global_position
	
	var movement_direction:Vector3 = start_position.direction_to(end_position)
	assert_vector(movement_direction).is_equal_approx(Vector3.FORWARD, Vector3(0.01, 0.1, 0.01))

func test_move_back():
	# Simulate input for key D
	runner.simulate_key_press(KEY_S)
	await await_millis(1500)
	runner.simulate_key_release(KEY_S)

	# Player moves backwards
	var end_position:Vector3 = player.global_position
	
	var movement_direction:Vector3 = start_position.direction_to(end_position)
	assert_vector(movement_direction).is_equal_approx(Vector3.BACK, Vector3(0.01, 0.1, 0.01))

func test_jump():
	# Simulate input for key SPACE
	await await_millis(500)
	runner.simulate_action_pressed("Jump")
	await await_idle_frame()

	# Player jumps
	assert_float(player.velocity.y).is_equal_approx(4.5, 0.1)
