extends RigidBody3D
class_name Pipette

func use(object_in_los):
	if object_in_los.get("pH"):
		object_in_los.pH -= 0.1
