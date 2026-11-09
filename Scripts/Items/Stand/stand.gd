extends Node3D
class_name Stand

func get_held_position():
	var ring = self.find_child("Ring")
	var target_pos = ring.global_position
	return target_pos
