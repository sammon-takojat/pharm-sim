extends GdUnitTestSuite

var scale_script = preload("res://Scripts/Items/Scale/ScaleArea.gd")

var scale


func before_test() -> void:
	scale = scale_script.new()
	add_child(scale)


func after_test() -> void:
	scale.queue_free()
	scale = null

func create_scale():
	return scale_script.new()


func create_body(mass: float) -> RigidBody3D:
	var body := RigidBody3D.new()
	body.mass = mass
	return body


func test_initial_weight_is_zero() -> void:
	var scale = create_scale()

	assert_float(scale.weight).is_equal(0.0)
	assert_float(scale.base_weight).is_equal(0.0)
	assert_array(scale.objects_on_scale).is_empty()


func test_add_body_adds_its_mass() -> void:
	var scale = create_scale()
	var body := create_body(5.0)

	scale.add_weight(body)

	assert_float(scale.weight).is_equal(5.0)
	assert_array(scale.objects_on_scale).contains_exactly([body])


func test_add_multiple_bodies_adds_all_masses() -> void:
	var scale = create_scale()
	var body_a := create_body(5.0)
	var body_b := create_body(3.0)

	scale.add_weight(body_a)
	scale.add_weight(body_b)

	assert_float(scale.weight).is_equal(8.0)


func test_same_body_is_not_counted_twice() -> void:
	var scale = create_scale()
	var body := create_body(5.0)

	scale.add_weight(body)
	scale.add_weight(body)

	assert_float(scale.weight).is_equal(5.0)
	assert_int(scale.objects_on_scale.size()).is_equal(1)


func test_remove_body_removes_its_mass() -> void:
	var scale = create_scale()
	var body_a := create_body(5.0)
	var body_b := create_body(3.0)

	scale.add_weight(body_a)
	scale.add_weight(body_b)

	scale.lose_weight(body_a)

	assert_float(scale.weight).is_equal(3.0)
	assert_array(scale.objects_on_scale).contains_exactly([body_b])


func test_remove_body_that_is_not_on_scale_does_nothing() -> void:
	var scale = create_scale()
	var body_a := create_body(5.0)
	var body_b := create_body(3.0)

	scale.add_weight(body_a)
	scale.lose_weight(body_b)

	assert_float(scale.weight).is_equal(5.0)
	assert_array(scale.objects_on_scale).contains_exactly([body_a])


func test_tare_sets_current_weight_to_zero() -> void:
	var scale = create_scale()
	var body_a := create_body(5.0)
	var body_b := create_body(3.0)

	scale.add_weight(body_a)
	scale.add_weight(body_b)

	scale.tare()

	assert_float(scale.weight).is_equal(0.0)
	assert_float(scale.base_weight).is_equal(-8.0)


func test_weight_after_tare_only_counts_new_weight() -> void:
	var scale = create_scale()
	var old_body := create_body(8.0)
	var new_body := create_body(3.0)

	scale.add_weight(old_body)
	scale.tare()

	scale.add_weight(new_body)

	assert_float(scale.weight).is_equal(3.0)


func test_removing_object_after_tare_updates_weight() -> void:
	var scale = create_scale()
	var body_a := create_body(5.0)
	var body_b := create_body(3.0)

	scale.add_weight(body_a)
	scale.add_weight(body_b)

	scale.tare()
	scale.lose_weight(body_a)

	assert_float(scale.weight).is_equal(-5.0)


func test_calculate_weight_uses_base_weight() -> void:
	var scale = create_scale()
	var body := create_body(5.0)

	scale.base_weight = -2.0
	scale.objects_on_scale.append(body)

	scale.calculate_weight()

	assert_float(scale.weight).is_equal(3.0)


func test_weight_changed_signal_is_emitted_when_adding() -> void:
	var body := create_body(5.0)

	monitor_signals(scale)

	scale.add_weight(body)

	await assert_signal(scale).is_emitted(
		scale.weight_changed,
		5.0
	)


func test_weight_changed_signal_is_emitted_when_removing() -> void:
	var body := create_body(5.0)

	scale.add_weight(body)

	monitor_signals(scale)

	scale.lose_weight(body)

	await assert_signal(scale).is_emitted(
		scale.weight_changed,
		0.0
	)


func test_weight_changed_signal_when_taring() -> void:
	var body := create_body(5.0)

	scale.add_weight(body)

	monitor_signals(scale)

	scale.tare()

	await assert_signal(scale).is_emitted(
		scale.weight_changed,
		0.0
	)
