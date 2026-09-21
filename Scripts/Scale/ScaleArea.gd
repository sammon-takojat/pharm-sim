extends Area3D

var weight : float

signal weight_changed(new_weight: float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_monitoring(true)
	body_entered.connect(addWeight)
	body_exited.connect(loseWeight)

func addWeight(body: Node3D) -> void:
	if body is RigidBody3D:
		weight += body.mass
		weight_changed.emit(weight)

func loseWeight(body: Node3D) -> void:
	if body is RigidBody3D:
		weight -= body.mass
		weight_changed.emit(weight)
