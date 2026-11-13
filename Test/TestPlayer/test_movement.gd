extends GdUnitTestSuite
## Script for testing player movement

var runner:GdUnitSceneRunner
var player:CharacterBody3D

## Initialize the environment before testing
func before_test():
	## Setup the scene
	runner = scene_runner("res://Test/TestScenes/TestScene.tscn")
	player = runner.find_child("Player")

## The function tests that the player moves to the appropriate direction
## when simulating movement inputs.
func test_player_movement(key:Key, direction:Vector3, _test_parameters := [
	[KEY_A, Vector3.LEFT],
	[KEY_D, Vector3.RIGHT],
	[KEY_W, Vector3.FORWARD],
	[KEY_S, Vector3.BACK]
	]):

	## Player position in the beginning of the test
	var start_position:Vector3 = player.global_position

	## Simulate input for movement
	runner.simulate_key_press(key)
	await await_millis(1500)
	runner.simulate_key_release(key)

	## Player position after inputs
	var end_position:Vector3 = player.global_position
	
	## Vector representing movement direction
	var movement_direction:Vector3 = start_position.direction_to(end_position)
	
	## Check that the movement direction matches the appropriate direction within
	## set error tolerances.
	assert_vector(movement_direction).is_equal_approx(direction, Vector3(0.01, 0.1, 0.01))

## The function tests that the player jumps when simulating input for jump.
func test_jump():
	await await_millis(500)
	
	## Simulate input for key SPACE
	runner.simulate_action_pressed("Jump")

	await runner.await_input_processed()
	runner.simulate_frames(10)

	## Check that the players vertical velocity matches the jump velocity
	## set in movement script.
	assert_float(player.velocity.y).is_equal_approx(4.0, 1.0)
