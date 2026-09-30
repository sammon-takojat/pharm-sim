extends RigidBody3D
class_name Pipette

var is_filled : bool
var stored_pH : float
var stored_molarity : float = 0.1

func use(object_in_los):
	if object_in_los and object_in_los.has_method("change_pH"):
		object_in_los.change_pH(0.05, stored_molarity)
