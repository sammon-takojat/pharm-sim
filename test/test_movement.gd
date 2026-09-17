extends GdUnitTestSuite

var runner:GdUnitSceneRunner
var player:CharacterBody3D

func before_test():
	# Setup the scene
	runner = scene_runner("res://Scenes/World.tscn")
	player = runner.find_child("Player")

func test_player_movement(key:Key, direction:Vector3, _test_parameters := [
	[KEY_A, Vector3.LEFT],
	[KEY_D, Vector3.RIGHT],
	[KEY_W, Vector3.FORWARD],
	[KEY_S, Vector3.BACK]
	]):

	# Get start position
	var start_position:Vector3 = player.global_position

	# Simulate input for movement
	runner.simulate_key_press(key)
	await await_millis(1500)
	runner.simulate_key_release(key)

	# Player moves to the correct direction
	var end_position:Vector3 = player.global_position
	var movement_direction:Vector3 = start_position.direction_to(end_position)
	assert_vector(movement_direction).is_equal_approx(direction, Vector3(0.01, 0.1, 0.01))

func test_jump():
	# Simulate input for key SPACE
	await await_millis(500)
	runner.simulate_action_pressed("Jump")
	await await_idle_frame()

	# Player jumps
	assert_float(player.velocity.y).is_equal_approx(4.5, 1.0)
