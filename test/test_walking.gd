extends GdUnitTestSuite

func test_player_movement():
	var runner := scene_runner("res://Scenes/World.tscn")
	var player:CharacterBody3D = runner.find_child("Player")

	var start_position:Vector3 = player.global_position

	runner.simulate_key_press(KEY_D)
	await await_millis(1000)
	runner.simulate_key_release(KEY_D)

	var end_position:Vector3 = player.global_position
	
	var movement_direction:Vector3 = start_position.direction_to(end_position)
	assert_vector(movement_direction).is_equal_approx(Vector3.RIGHT, Vector3(0.1, 0.1, 0.1))
