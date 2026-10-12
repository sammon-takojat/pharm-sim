extends GdUnitTestSuite


var pipette_script = preload(
	"res://Scripts/Items/PasteurPipette/pasteur_pipette.gd"
)

var liquid_container_script = preload(
	"res://Scripts/Items/Beaker/beaker_liquid.gd"
)

var pipettes: Array[Pipette] = []
var containers: Array[LiquidContainer] = []


func after_test() -> void:
	for pipette in pipettes:
		if is_instance_valid(pipette):
			pipette.queue_free()

	for container in containers:
		if is_instance_valid(container):
			container.queue_free()

	pipettes.clear()
	containers.clear()


func create_pipette() -> Pipette:
	var pipette: Pipette = pipette_script.new()

	add_child(pipette)
	pipettes.append(pipette)

	return pipette


func create_container(
	fill_ml: float = 0.0,
	initial_ph: float = 7.0
) -> LiquidContainer:
	var container: LiquidContainer = liquid_container_script.new()

	container.fill_amount_ml = fill_ml
	container.pH = initial_ph

	var circle := MeshInstance3D.new()
	circle.name = "Circle2"

	var mesh := SphereMesh.new()
	circle.mesh = mesh

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


func test_empty_pipette_has_zero_molarity() -> void:
	var pipette := create_pipette()

	assert_float(pipette.volume_ml).is_equal(0.0)
	assert_float(pipette.net_h_moles).is_equal(0.0)
	assert_float(pipette.get_molarity()).is_equal(0.0)
	assert_bool(pipette.is_filled).is_false()


func test_get_molarity() -> void:
	var pipette := create_pipette()

	pipette.volume_ml = 10.0
	pipette.net_h_moles = 0.01

	assert_float(pipette.get_molarity()).is_equal(1.0)


func test_get_molarity_uses_absolute_moles() -> void:
	var pipette := create_pipette()

	pipette.volume_ml = 10.0
	pipette.net_h_moles = -0.01

	assert_float(pipette.get_molarity()).is_equal(1.0)


func test_fill_pipette_from_container() -> void:
	var pipette := create_pipette()
	var container := create_container(100.0)

	pipette.use(container)

	assert_bool(pipette.is_filled).is_true()
	assert_float(pipette.volume_ml).is_equal(10.0)
	assert_float(pipette.net_h_moles).is_equal_approx(
		0.0,
		0.000001
	)

	assert_float(container.fill_amount_ml).is_equal(90.0)


func test_fill_pipette_takes_only_available_liquid() -> void:
	var pipette := create_pipette()
	var container := create_container(5.0)

	pipette.use(container)

	assert_bool(pipette.is_filled).is_true()
	assert_float(pipette.volume_ml).is_equal(5.0)
	assert_float(container.fill_amount_ml).is_equal(0.0)


func test_fill_pipette_with_acid_preserves_moles() -> void:
	var pipette := create_pipette()
	var container := create_container(100.0)

	# 1 M acid, 100 ml = 0.1 mol
	container.net_h_moles = 0.1

	pipette.use(container)

	assert_float(pipette.volume_ml).is_equal(10.0)
	assert_float(pipette.net_h_moles).is_equal_approx(
		0.01,
		0.000001
	)

	assert_float(
		pipette.get_molarity()
	).is_equal_approx(
		1.0,
		0.0001
	)


func test_dispensing_acid_transfers_correct_amount() -> void:
	var pipette := create_pipette()
	var target := create_container(100.0)

	pipette.volume_ml = 10.0
	pipette.net_h_moles = 0.01
	pipette.is_filled = true

	pipette.use(target)

	# dispense_amount_ml = 0.05 ml
	# 1 M => 0.00005 mol transferred
	assert_float(pipette.volume_ml).is_equal_approx(
		9.95,
		0.000001
	)

	assert_float(pipette.net_h_moles).is_equal_approx(
		0.00995,
		0.000001
	)

	assert_float(target.fill_amount_ml).is_equal_approx(
		100.05,
		0.000001
	)

	assert_float(target.net_h_moles).is_equal_approx(
		0.00005,
		0.000001
	)


func test_dispensing_base_transfers_negative_moles() -> void:
	var pipette := create_pipette()
	var target := create_container(100.0)

	pipette.volume_ml = 10.0
	pipette.net_h_moles = -0.01
	pipette.is_filled = true

	pipette.use(target)

	assert_float(pipette.net_h_moles).is_equal_approx(
		-0.00995,
		0.000001
	)

	assert_float(target.net_h_moles).is_equal_approx(
		-0.00005,
		0.000001
	)


func test_dispensing_acid_lowers_target_ph() -> void:
	var pipette := create_pipette()
	var target := create_container(100.0)

	pipette.volume_ml = 10.0
	pipette.net_h_moles = 0.01
	pipette.is_filled = true

	pipette.use(target)

	assert_float(target.pH).is_less(7.0)
	assert_float(target.pH).is_equal_approx(
		3.301247,
		0.0001
	)


func test_dispensing_base_raises_target_ph() -> void:
	var pipette := create_pipette()
	var target := create_container(100.0)

	pipette.volume_ml = 10.0
	pipette.net_h_moles = -0.01
	pipette.is_filled = true

	pipette.use(target)

	assert_float(target.pH).is_greater(7.0)


func test_dispensing_last_amount_empties_pipette() -> void:
	var pipette := create_pipette()
	var target := create_container(100.0)

	pipette.volume_ml = 0.05
	pipette.net_h_moles = 0.00005
	pipette.is_filled = true

	pipette.use(target)

	assert_float(pipette.volume_ml).is_equal(0.0)
	assert_float(pipette.net_h_moles).is_equal(0.0)
	assert_bool(pipette.is_filled).is_false()
