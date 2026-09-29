extends StaticBody3D
class_name Button3D

signal pressed()

func press():
	emit_signal("pressed")
