extends RigidBody3D
class_name Pipette

@export var capacity_ml: float = 10.0
@export var dispense_amount_ml: float = 0.05
@export var mesh: MeshInstance3D
var liquid: Liquid

func use(object_in_los) -> void:
	if object_in_los and "reagent" in object_in_los and !liquid:
		liquid = object_in_los.reagent.remove_liquid(capacity_ml)
		liquid._mesh = mesh
	elif object_in_los and "reagent" in object_in_los:
		if liquid == null:
			return
		
		var sample = liquid.remove_liquid(dispense_amount_ml)

		object_in_los.reagent.add_liquid(sample)
		if liquid._fill_amount_ml <= 0.0001:
			liquid = null
	elif object_in_los is PH_Paper:
		if !liquid:
			return
		object_in_los.changeColor(liquid._pH)
