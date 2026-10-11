extends GdUnitTestSuite

var runner:GdUnitSceneRunner
var player_head:Node3D
var hood:Node3D


func before_test():
	
	var scene = auto_free(load("res://Test/TestScenes/TestScene.tscn").instantiate())
	var player = scene.find_child("Player")
	var hood_init = auto_free(load("res://Scenes/Environment/FumeHood.tscn").instantiate())
	scene.add_child(hood_init)
	hood_init.transform.origin = player.transform.origin + Vector3(-2, -1, 0)
	
	runner = scene_runner(scene)
	player_head = runner.find_child("Player").find_child("Head")
	hood = runner.find_child("FumeHood")

func test_open_hood_handle():
	await await_millis(500)
	player_head.look_at(hood.find_child("handle").global_position)
	await await_idle_frame()
	runner.simulate_key_pressed(KEY_E)
	await await_idle_frame()
	
	assert_that(hood.find_child("AnimationPlayer").current_animation).is_equal("open")
	
	await await_millis(500)
	
	assert_that(hood.opened).is_equal(true)
	assert_that(hood.up).is_equal(true)
	
func test_open_hood_lowerGlass():	
	await await_millis(500)
	player_head.look_at(hood.find_child("lowerGlass").global_position)
	await await_idle_frame()
	runner.simulate_key_pressed(KEY_E)
	await await_idle_frame()
	
	assert_that(hood.find_child("AnimationPlayer").current_animation).is_equal("open")
	
	await await_millis(500)
	
	assert_that(hood.opened).is_equal(true)
	assert_that(hood.up).is_equal(true)

func test_lower_hood_handle():
	hood.find_child("AnimationPlayer").play("open")
	hood.opened = true
	hood.up = true
	
	await await_millis(1000)
	player_head.look_at(hood.find_child("handle").global_position)
	await await_millis(1000)
	runner.simulate_key_pressed(KEY_E)
	await await_idle_frame()
	
	assert_that(hood.find_child("AnimationPlayer").current_animation).is_equal("open")
	
	await await_millis(500)
	
	assert_that(hood.opened).is_equal(false)
	assert_that(hood.up).is_equal(false)

func test_lower_hood_lowerGlass():
	hood.find_child("AnimationPlayer").play("open")
	hood.opened = true
	hood.up = true
	
	await await_millis(500)
	player_head.look_at(hood.find_child("lowerGlass").global_position)
	await await_idle_frame()
	runner.simulate_key_pressed(KEY_E)
	await await_idle_frame()
	
	assert_that(hood.find_child("AnimationPlayer").current_animation).is_equal("open")
	
	await await_millis(500)
	
	assert_that(hood.opened).is_equal(false)
	assert_that(hood.up).is_equal(false)
