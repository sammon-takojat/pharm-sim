extends RigidBody3D
class_name Pipette

func use(object_in_los):
	if object_in_los and object_in_los.get("pH"):
		object_in_los.pH = max(object_in_los.pH - 0.5, 0.1)
		object_in_los.change_fill_amount(15.0)
