extends RigidBody3D
class_name Suppilo
## Script for funnel functions

@onready var suppilo = $"."
signal drop_object ## Signal for removing the funnel from the players hand

## The function looks for get_hold_position method in the target object and
## calls it if found. Then sets the position of the funnel to the returned
## position and freezes it.
func use(object_in_los) -> void:
	if object_in_los == null:
		return
	
	var parent_node = object_in_los
	
	while parent_node != null:
		if parent_node.has_method("get_hold_position"):
			var target_pos = parent_node.get_hold_position()
			drop_object.emit()
			suppilo.freeze = true
			suppilo.global_position = target_pos
			suppilo.global_rotation = Vector3(0, 0, 0)
			return
		parent_node = parent_node.get_parent()
