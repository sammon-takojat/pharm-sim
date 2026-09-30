extends Area3D

var weight : float
var base_weight : float
var objects_on_scale : Dictionary

signal weight_changed(new_weight: float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_monitoring(true)
	body_entered.connect(add_weight)
	body_exited.connect(lose_weight)
	var button = $"../../Button"
	button.pressed.connect(tare)

func add_weight(body: Node3D) -> void:
	if body is RigidBody3D:
		if objects_on_scale.has(body):
			pass
		else: 
			objects_on_scale[body] = body.mass
			calculate_weight()
			weight_changed.emit(weight)

func lose_weight(body: Node3D) -> void:
	if body is RigidBody3D:
		if objects_on_scale.has(body):
			objects_on_scale.erase(body)
			calculate_weight()
			weight_changed.emit(weight)

func tare() -> void:
	base_weight = 0
	for object in objects_on_scale:
		base_weight -= objects_on_scale[object]
	calculate_weight()
	weight_changed.emit(weight)

func calculate_weight() -> void:
	weight = base_weight
	for object in objects_on_scale:
		weight += objects_on_scale[object]
