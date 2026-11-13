extends GdUnitTestSuite


var liquid_container_script = preload(
	"res://Scripts/Items/Beaker/beaker_liquid.gd"
)

var containers: Array[LiquidContainer] = []
var container: LiquidContainer

func before_test() -> void:
	var fill_ml: float = 100.0
	var initial_ph: float = 7.0
	container = liquid_container_script.new()

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

func after_test() -> void:
	for cont in containers:
		if is_instance_valid(cont):
			cont.queue_free()

	containers.clear()

func test_add_acid_lowers_ph() -> void:
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

func test_add_base_raises_ph() -> void:
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

func test_empty_container_has_neutral_ph() -> void:
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

func test_add_acid_increases_hydrogen_moles() -> void:
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

func test_add_base_decreases_hydrogen_moles() -> void:
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

func test_remove_liquid_returns_correct_volume_and_moles() -> void:
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
