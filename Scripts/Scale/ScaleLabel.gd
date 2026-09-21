extends Label3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var area = $"../StaticBody3D/Area3D"
	area.weight_changed.connect(changeText)


func changeText(new_weight: float):
	text = "Weight: %s" % new_weight
