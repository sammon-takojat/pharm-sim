extends GdUnitTestSuite

var runner:GdUnitSceneRunner
var player_head:Node3D
var cube:RigidBody3D
var cube_hand_pos:Vector3

func before_test():
	
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
	var player = scene.find_child("Player")
	cube_init.transform.origin = player.global_position + Vector3(0, 1, -2)
	cube_init.add_to_group("pickable")
	
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
	await await_millis(500)
	cube_hand_pos = cube.global_position
	runner.simulate_mouse_move_relative(Vector2(0, -200))
	await await_millis(500)
	assert_that(cube.global_position.y).is_greater(cube_hand_pos.y)

func test_move_object_down():
	player_head.held_object = cube
	await await_millis(500)
	cube_hand_pos = cube.global_position
	runner.simulate_mouse_move_relative(Vector2(0, 200))
	await await_millis(500)
	assert_that(cube.global_position.y).is_less(cube_hand_pos.y)

func test_move_object_left():
	player_head.held_object = cube
	await await_millis(500)
	cube_hand_pos = cube.global_position
	runner.simulate_mouse_move_relative(Vector2(-200, 0))
	await await_millis(500)
	assert_that(cube.global_position.x).is_less(cube_hand_pos.x)

func test_move_object_right():
	player_head.held_object = cube
	await await_millis(500)
	cube_hand_pos = cube.global_position
	runner.simulate_mouse_move_relative(Vector2(200, 0))
	await await_millis(500)
	assert_that(cube.global_position.x).is_greater(cube_hand_pos.x)

func test_move_object_forward():
	player_head.held_object = cube
	await await_millis(500)
	cube_hand_pos = cube.global_position
	for i in range(2):
		runner.simulate_mouse_button_press(MOUSE_BUTTON_WHEEL_UP)
		await await_millis(500)
		runner.simulate_mouse_button_release(MOUSE_BUTTON_WHEEL_UP)
	assert_that(cube.global_position.z).is_less(cube_hand_pos.z)

func test_move_object_back():
	player_head.held_object = cube
	await await_millis(500)
	cube_hand_pos = cube.global_position
	for i in range(2):
		runner.simulate_mouse_button_press(MOUSE_BUTTON_WHEEL_DOWN)
		await await_millis(500)
		runner.simulate_mouse_button_release(MOUSE_BUTTON_WHEEL_DOWN)
	assert_that(cube.global_position.z).is_greater(cube_hand_pos.z)

func test_move_object_with_player_right():
	player_head.held_object = cube
	await await_millis(500)
	cube_hand_pos = cube.global_position
	runner.simulate_key_press(KEY_D)
	await await_millis(500)
	runner.simulate_key_release(KEY_D)
	assert_that(cube.global_position.x).is_greater(cube_hand_pos.x)

func test_move_object_with_player_left():
	player_head.held_object = cube
	await await_millis(500)
	cube_hand_pos = cube.global_position
	runner.simulate_key_press(KEY_A)
	await await_millis(500)
	runner.simulate_key_release(KEY_A)
	assert_that(cube.global_position.x).is_less(cube_hand_pos.x)

func test_move_object_with_player_forward():
	player_head.held_object = cube
	await await_millis(500)
	cube_hand_pos = cube.global_position
	runner.simulate_key_press(KEY_W)
	await await_millis(500)
	runner.simulate_key_release(KEY_W)
	assert_that(cube.global_position.z).is_less(cube_hand_pos.z)

func test_move_object_with_player_back():
	player_head.held_object = cube
	await await_millis(500)
	cube_hand_pos = cube.global_position
	runner.simulate_key_press(KEY_S)
	await await_millis(500)
	runner.simulate_key_release(KEY_S)
	assert_that(cube.global_position.z).is_greater(cube_hand_pos.z)
