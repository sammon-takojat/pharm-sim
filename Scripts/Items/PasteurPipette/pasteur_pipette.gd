extends RigidBody3D
class_name Pipette

<<<<<<< HEAD
func use(object_in_los):
	if object_in_los and object_in_los.get("pH"):
		object_in_los.pH = max(object_in_los.pH - 0.5, 0.1)
		object_in_los.change_fill_amount(15.0)
=======
@export var capacity_ml: float = 10.0
@export var dispense_amount_ml: float = 0.05

var is_filled : bool
var volume_ml : float
var net_h_moles: float

func get_molarity() -> float:
	if volume_ml <= 0.0:
		return 0.0

	return abs(net_h_moles) / (volume_ml / 1000.0)

func use(object_in_los):
	if object_in_los and object_in_los.has_method("remove_liquid") and not is_filled:
		var res = object_in_los.remove_liquid(capacity_ml)
		net_h_moles += res["net_h_moles"]
		volume_ml += res["volume_ml"]
		is_filled = true
	elif object_in_los and object_in_los.has_method("add_reagent"):
		var amount_ml = min(dispense_amount_ml, volume_ml)
		amount_ml = min(amount_ml, volume_ml)
		
		var molarity = get_molarity()
		var is_base = net_h_moles < 0.0
		
		object_in_los.add_reagent(amount_ml, molarity, is_base)
		
		var fraction = amount_ml / volume_ml
		var transferred_moles = net_h_moles * fraction
		
		net_h_moles -= transferred_moles
		volume_ml -= amount_ml
		
		if volume_ml <= 0.0001:
			volume_ml = 0.0
			net_h_moles = 0.0
			is_filled = false
>>>>>>> dev
