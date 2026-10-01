extends RigidBody3D
class_name LiquidContainer

@export var pH := 7.0

@export var fill_amount_ml : float
var net_h_moles: float

@export var MAX_FILL_ML := 250.0
@export var EMPTY_MASS := 0.100
var FULL_LIQUID_MASS := MAX_FILL_ML / 1000.0

@onready var material := $Circle2.get_surface_override_material(0) as ShaderMaterial

signal mass_changed

#Fill amount clamp (0.462, 0.538)

func _ready():
	var fill_percent = inverse_lerp(0.0, MAX_FILL_ML, fill_amount_ml)
	var start_fill_amount = lerp(0.461, 0.538, fill_percent)
	material.set_shader_parameter("fill_amount", start_fill_amount)
	mass = lerp(0.0, 0.250, start_fill_amount)
	var h_concentration = pow(10.0, -pH)
	var oh_concentration = pow(10.0, pH - 14.0)
	
	var net_concentration = h_concentration - oh_concentration
	net_h_moles = net_concentration * (fill_amount_ml / 1000.0)
	
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
	emit_signal("mass_changed")
	
func add_reagent(amount_ml: float, molarity: float, is_base: bool):
	var added_moles = (amount_ml / 1000.0) * molarity
	
	if is_base:
		net_h_moles -= added_moles
	else:
		net_h_moles += added_moles
	
	update_pH()
	change_fill_amount(amount_ml)
	
func remove_liquid(amount_ml: float) -> Dictionary:
	var removed_amount = min(amount_ml, fill_amount_ml)
	
	var fraction = removed_amount / fill_amount_ml
	
	var removed_moles = net_h_moles * fraction
	
	net_h_moles -= removed_moles
	fill_amount_ml -= removed_amount
	
	update_pH()
	change_fill_amount(-amount_ml)
	
	return {
		"volume_ml": removed_amount,
		"net_h_moles": removed_moles
	}	

func update_pH():
	if fill_amount_ml <= 0.0:
		pH = 7.0
		return
	
	var volume_l = fill_amount_ml / 1000.0
	var net_concentration = net_h_moles / volume_l
	
	var kw = 1.0e-14
	var h_concentration = (
		net_concentration + sqrt(net_concentration + net_concentration + 4.0 * kw)
	) / 2.0
	
	pH = -log(h_concentration) / log(10.0)
	
	print("pH: ", pH)
