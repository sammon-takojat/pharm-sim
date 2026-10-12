extends GdUnitTestSuite


var liquid_container_script = preload(
	"res://Scripts/Items/Beaker/beaker_liquid.gd"
)

var containers: Array[LiquidContainer] = []


func after_test() -> void:
	for container in containers:
		if is_instance_valid(container):
			container.queue_free()

	containers.clear()


func create_container(
	fill_ml: float = 0.0,
	initial_ph: float = 7.0
) -> LiquidContainer:
	var container: LiquidContainer = liquid_container_script.new()

	container.fill_amount_ml = fill_ml
	container.pH = initial_ph

	# LiquidContainer expects a child called Circle2.
	var circle := MeshInstance3D.new()
	circle.name = "Circle2"

	var mesh := SphereMesh.new()
	circle.mesh = mesh

	# Give Circle2 a ShaderMaterial so LiquidContainer._ready()
	# can duplicate it and call set_shader_parameter().
	var shader := Shader.new()
	shader.code = """
		shader_type spatial;

		uniform float fill_amount;

		void fragment() {
			ALBEDO = vec3(fill_amount);
		}
	"""

	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader

	circle.set_surface_override_material(0, shader_material)

	container.add_child(circle)

	add_child(container)
	containers.append(container)

	return container


func test_empty_container_has_empty_mass() -> void:
	var container := create_container()

	assert_float(container.fill_amount_ml).is_equal_approx(
		0.0,
		0.000001
	)

	assert_float(container.mass).is_equal_approx(
		0.100,
		0.000001
	)

	assert_float(container.pH).is_equal_approx(
		7.0,
		0.000001
	)

	assert_float(container.net_h_moles).is_equal_approx(
		0.0,
		0.000001
	)


func test_initial_mass_matches_fill_amount() -> void:
	var container := create_container(125.0)

	# 125 / 250 = 0.5
	# liquid mass = 0.125 kg
	# empty mass = 0.100 kg
	# total = 0.225 kg
	assert_float(container.mass).is_equal_approx(
		0.225,
		0.000001
	)


func test_change_fill_amount_increases_volume_and_mass() -> void:
	var container := create_container()

	container.change_fill_amount(100.0)

	assert_float(container.fill_amount_ml).is_equal_approx(
		100.0,
		0.000001
	)

	assert_float(container.mass).is_equal_approx(
		0.200,
		0.000001
	)


func test_change_fill_amount_cannot_exceed_maximum() -> void:
	var container := create_container()

	container.change_fill_amount(300.0)

	assert_float(container.fill_amount_ml).is_equal_approx(
		250.0,
		0.000001
	)

	assert_float(container.mass).is_equal_approx(
		0.350,
		0.000001
	)


func test_change_fill_amount_cannot_go_below_zero() -> void:
	var container := create_container(100.0)

	container.change_fill_amount(-200.0)

	assert_float(container.fill_amount_ml).is_equal_approx(
		0.0,
		0.000001
	)

	assert_float(container.mass).is_equal_approx(
		0.100,
		0.000001
	)


func test_add_acid_increases_hydrogen_moles() -> void:
	var container := create_container(100.0)

	container.add_reagent(
		10.0,
		1.0,
		false
	)

	assert_float(container.fill_amount_ml).is_equal_approx(
		110.0,
		0.000001
	)

	assert_float(container.net_h_moles).is_equal_approx(
		0.010,
		0.000001
	)


func test_add_acid_lowers_ph() -> void:
	var container := create_container(100.0)

	container.add_reagent(
		10.0,
		1.0,
		false
	)

	# 0.01 mol / 0.11 L = 0.090909 M
	# pH ≈ 1.041393
	assert_float(container.pH).is_equal_approx(
		1.0413927,
		0.0001
	)


func test_add_base_decreases_hydrogen_moles() -> void:
	var container := create_container(100.0)

	container.add_reagent(
		10.0,
		1.0,
		true
	)

	assert_float(container.fill_amount_ml).is_equal_approx(
		110.0,
		0.000001
	)

	assert_float(container.net_h_moles).is_equal_approx(
		-0.010,
		0.000001
	)


func test_add_base_raises_ph() -> void:
	var container := create_container(100.0)

	container.add_reagent(
		10.0,
		1.0,
		true
	)

	# pH ≈ 12.958607
	assert_float(container.pH).is_equal_approx(
		12.9586073,
		0.0001
	)


func test_remove_liquid_returns_correct_volume_and_moles() -> void:
	var container := create_container(100.0)

	# Pretend the container contains 0.01 mol of H+.
	container.net_h_moles = 0.01

	var result := container.remove_liquid(25.0)

	assert_float(result["volume_ml"]).is_equal_approx(
		25.0,
		0.000001
	)

	assert_float(result["net_h_moles"]).is_equal_approx(
		0.0025,
		0.000001
	)

	assert_float(container.fill_amount_ml).is_equal_approx(
		75.0,
		0.000001
	)

	assert_float(container.net_h_moles).is_equal_approx(
		0.0075,
		0.000001
	)


func test_remove_liquid_cannot_remove_more_than_exists() -> void:
	var container := create_container(20.0)

	var result := container.remove_liquid(50.0)

	assert_float(result["volume_ml"]).is_equal_approx(
		20.0,
		0.000001
	)

	assert_float(result["net_h_moles"]).is_equal_approx(
		0.0,
		0.000001
	)

	assert_float(container.fill_amount_ml).is_equal_approx(
		0.0,
		0.000001
	)

	assert_float(container.pH).is_equal_approx(
		7.0,
		0.000001
	)


func test_empty_container_has_neutral_ph() -> void:
	var container := create_container(100.0)

	container.add_reagent(
		10.0,
		1.0,
		false
	)

	container.remove_liquid(110.0)

	assert_float(container.fill_amount_ml).is_equal_approx(
		0.0,
		0.000001
	)

	assert_float(container.pH).is_equal_approx(
		7.0,
		0.000001
	)


func test_mass_changed_signal_is_emitted_when_volume_changes() -> void:
	var container := create_container()

	monitor_signals(container)

	container.change_fill_amount(10.0)

	await assert_signal(container).is_emitted(
		container.mass_changed
	)


func test_mass_changed_signal_is_emitted_when_adding_reagent() -> void:
	var container := create_container(100.0)

	monitor_signals(container)

	container.add_reagent(
		10.0,
		1.0,
		false
	)

	await assert_signal(container).is_emitted(
		container.mass_changed
	)


func test_mass_changed_signal_is_emitted_when_removing_liquid() -> void:
	var container := create_container(100.0)

	monitor_signals(container)

	container.remove_liquid(10.0)

	await assert_signal(container).is_emitted(
		container.mass_changed
	)
