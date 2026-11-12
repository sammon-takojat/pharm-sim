extends Node3D
class_name Stand
## Script for stand functions

## This function returns the position of the "Ring" node.
func get_hold_position():
	var ring = self.find_child("Ring")
	var target_pos = ring.global_position
	return target_pos
