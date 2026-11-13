class_name LiquidContainer extends RigidBody3D


@export var pH := 7.0

@export var fill_amount_ml : float
var net_h_moles: float

@export var MAX_FILL_ML := 250.0
@export var EMPTY_MASS := 0.100
var FULL_LIQUID_MASS := MAX_FILL_ML / 1000.0
var reagent : Reagents

@export var mesh : MeshInstance3D

signal mass_changed

func _ready():
	var fill_percent = fill_amount_ml / MAX_FILL_ML
	self.mass = lerp(0.0, MAX_FILL_ML/1000, fill_percent) + EMPTY_MASS
	var liquid := Liquid.new()
	liquid.initialize(fill_amount_ml, pH, MAX_FILL_ML, mesh)
	reagent = liquid
	
func calculate_mass(amount_ml: float):
	fill_amount_ml = clamp(
		fill_amount_ml + amount_ml,
		0.0,
		MAX_FILL_ML
	)
	var fill_percent = fill_amount_ml / MAX_FILL_ML
	
	mass = lerp(
		EMPTY_MASS,
		EMPTY_MASS + FULL_LIQUID_MASS,
		fill_percent
	)
	emit_signal("mass_changed")
	
func add_reagent(amount_ml: float, molarity: float, is_base: bool):
	reagent.add_reagent(amount_ml, molarity, is_base)
	
	calculate_mass(amount_ml)

	
func remove_liquid(amount_ml: float) -> Dictionary:
	calculate_mass(-amount_ml)
	return reagent.remove_liquid(amount_ml)
