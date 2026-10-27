extends GdUnitTestSuite


var pipette_script = preload(
	"res://Scripts/Items/PasteurPipette/pasteur_pipette.gd"
)

var liquid_container_script = preload(
	"res://Scripts/Items/Beaker/beaker_liquid.gd"
)

var pipettes: Array[Pipette] = []
var containers: Array[LiquidContainer] = []
var pipette: Pipette
var container_100: LiquidContainer


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

func before_test():
	pipette = create_pipette()
	container_100 = create_container(100.0)


func test_fill_pipette_from_container() -> void:

	pipette.use(container_100)

	assert_bool(pipette.is_filled).is_true()
	assert_float(pipette.volume_ml).is_equal(10.0)
	assert_float(pipette.net_h_moles).is_equal_approx(
		0.0,
		0.000001
	)

	assert_float(container_100.fill_amount_ml).is_equal(90.0)


func test_fill_pipette_takes_only_available_liquid() -> void:
	var container := create_container(5.0)

	pipette.use(container)

	assert_bool(pipette.is_filled).is_true()
	assert_float(pipette.volume_ml).is_equal(5.0)
	assert_float(container.fill_amount_ml).is_equal(0.0)


func test_dispensing_acid_transfers_correct_amount() -> void:

	pipette.volume_ml = 10.0
	pipette.net_h_moles = 0.01
	pipette.is_filled = true

	pipette.use(container_100)

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

	assert_float(container_100.fill_amount_ml).is_equal_approx(
		100.05,
		0.000001
	)

	assert_float(container_100.net_h_moles).is_equal_approx(
		0.00005,
		0.000001
	)

func test_dispensing_last_amount_empties_pipette() -> void:

	pipette.volume_ml = 0.05
	pipette.net_h_moles = 0.00005
	pipette.is_filled = true

	pipette.use(container_100)

	assert_float(pipette.volume_ml).is_equal(0.0)
	assert_float(pipette.net_h_moles).is_equal(0.0)
	assert_bool(pipette.is_filled).is_false()
