extends GdUnitTestSuite

var runner:GdUnitSceneRunner
var player_head:Node3D
var player_camera:Camera3D
var hood:Node3D


func before_test():
	
	var scene = auto_free(load("res://Test/TestScenes/TestScene.tscn").instantiate())
	var player = scene.find_child("Player")
	var hood_init = auto_free(load("res://Scenes/Environment/FumeHood.tscn").instantiate())
	scene.add_child(hood_init)
	hood_init.transform.origin = player.transform.origin + Vector3(-1.5, -1, 0)
	
	runner = scene_runner(scene)
	player = runner.find_child("Player")
	player_head = player.find_child("Head")
	player_camera = player_head.get_children()[0]
	hood = runner.find_child("FumeHood")

func test_open_hood_handle():
	await await_millis(500)
	player_head.look_at(hood.find_child("handle").global_position)
	await await_idle_frame()
	runner.simulate_key_pressed(KEY_E)
	await await_idle_frame()
	
	assert_that(hood.find_child("AnimationPlayer").current_animation).is_equal("open")
	
	runner.simulate_frames(60)
	
	assert_that(hood.opened).is_equal(true)
	assert_that(hood.up).is_equal(true)
	
func test_open_hood_lowerglass():	
	await await_millis(500)
	player_head.look_at(hood.find_child("lowerGlass").global_position)
	await await_idle_frame()
	runner.simulate_key_pressed(KEY_E)
	await await_idle_frame()
	
	assert_that(hood.find_child("AnimationPlayer").current_animation).is_equal("open")
	
	runner.simulate_frames(60)
	
	assert_that(hood.opened).is_equal(true)
	assert_that(hood.up).is_equal(true)

func test_lower_hood_handle():
	hood.find_child("AnimationPlayer").play("open")
	hood.opened = true
	hood.up = true
	
	await await_millis(1400)
	player_camera.look_at(hood.find_child("handle").global_position)
	await await_millis(1000)
	runner.simulate_key_pressed(KEY_E)
	await await_idle_frame()
	
	assert_that(hood.find_child("AnimationPlayer").current_animation).is_equal("open")
	
	await await_millis(1000)
	
	assert_that(hood.opened).is_equal(false)
	assert_that(hood.up).is_equal(false)

func test_lower_to_use_mode():
	hood.find_child("AnimationPlayer").play("open")
	hood.opened = true
	hood.up = true
	
	await await_millis(1400)
	player_camera.look_at(hood.find_child("handle").global_position)
	await await_millis(1000)
	runner.simulate_key_pressed(KEY_F)
	await await_idle_frame()
	
	assert_that(hood.find_child("AnimationPlayer").current_animation).is_equal("halfwaydown")
	
	await await_millis(1000)
	
	assert_that(hood.opened).is_equal(true)
	assert_that(hood.up).is_equal(false)


func test_raise_from_use_mode():
	hood.find_child("AnimationPlayer").play("halfwaydown")
	hood.opened = true
	hood.up = false
	
	await await_millis(1400)
	player_camera.look_at(hood.find_child("handle").global_position)
	await await_millis(1000)
	runner.simulate_key_pressed(KEY_F)
	await await_idle_frame()
	
	assert_that(hood.find_child("AnimationPlayer").current_animation).is_equal("halfwaydown")
	
	await await_millis(1000)
	
	assert_that(hood.opened).is_equal(true)
	assert_that(hood.up).is_equal(true)
