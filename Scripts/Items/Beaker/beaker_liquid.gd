extends RigidBody3D

var pH := 5.0

var fill_amount_ml := 3.25

const MAX_FILL_ML := 250.0
const EMPTY_MASS := 0.100
const FULL_LIQUID_MASS := 0.250

@onready var material := $Circle2.get_surface_override_material(0) as ShaderMaterial

#Fill amount clamp (0.462, 0.538)

func _ready():
	var start_fill_amount = inverse_lerp(0.461, 0.538, 0.462)
	material.set_shader_parameter("fill_amount", 0.462)
	mass = lerp(0.0, 0.250, start_fill_amount)
	
func change_fill_amount(amount_ml: float):
	fill_amount_ml = clamp(
		fill_amount_ml + amount_ml,
		0.0,
		MAX_FILL_ML
	)

	var fill_percent = fill_amount_ml / MAX_FILL_ML

	material.set_shader_parameter(
		"fill_amount",
		lerp(0.462, 0.538, fill_percent)
	)

	mass = lerp(
		EMPTY_MASS,
		EMPTY_MASS + FULL_LIQUID_MASS,
		fill_percent
	)
