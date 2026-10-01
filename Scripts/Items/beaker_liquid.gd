extends RigidBody3D

@export var pH := 7.0

@export var fill_amount_ml : float

@export var MAX_FILL_ML := 250.0
@export var EMPTY_MASS := 0.100
var FULL_LIQUID_MASS := MAX_FILL_ML / 1000.0

@onready var material := $Circle2.get_surface_override_material(0) as ShaderMaterial

#Fill amount clamp (0.462, 0.538)

func _ready():
	var fill_percent = inverse_lerp(0.0, MAX_FILL_ML, fill_amount_ml)
	var start_fill_amount = lerp(0.461, 0.538, fill_percent)
	material.set_shader_parameter("fill_amount", start_fill_amount)
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
	
func change_pH(amount_ml: float, molarity: float, is_base: bool):
	var initial_h_concentration = pow(10, -pH)
	var total_h_moles = (fill_amount_ml / 1000.0) * initial_h_concentration
	var moles_h = (amount_ml / 1000.0) * molarity
	var total_volume = (fill_amount_ml / 1000.0)+(amount_ml / 1000.0)
	change_fill_amount(amount_ml)
	if not is_base:
		total_h_moles += moles_h
	else:
		total_h_moles -= moles_h
	if total_h_moles > 0:
		var h_final = total_h_moles / total_volume
		pH = -log(h_final) / log(10)
	elif total_h_moles < 0:
		var excess_oh_moles = abs(total_h_moles)
		var oh_final = excess_oh_moles / total_volume
		var pOH = -log(oh_final) / log(10.0)
		pH = 14.0 - pOH
	else:
		pH = 7.0

	
	
