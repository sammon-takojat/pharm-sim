extends Area3D

var weight : float
var base_weight : float
var objects_on_scale : Array

signal weight_changed(new_weight: float)

@onready var button = $"../../Button"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_monitoring(true)
	body_entered.connect(add_weight)
	body_exited.connect(lose_weight)
	button.pressed.connect(tare)

func add_weight(body: Node3D) -> void:
	if body is RigidBody3D:
		if objects_on_scale.has(body):
			pass
		else: 
			if body is LiquidContainer:
				body.connect("mass_changed", on_body_weight_changed)
			objects_on_scale.append(body)
			calculate_weight()
			weight_changed.emit(weight)

func lose_weight(body: Node3D) -> void:
	if body is RigidBody3D:
		if objects_on_scale.has(body):
			if body is LiquidContainer:
				body.disconnect("mass_changed", on_body_weight_changed)
			objects_on_scale.erase(body)
			calculate_weight()
			weight_changed.emit(weight)

func tare() -> void:
	base_weight = 0
	for object in objects_on_scale:
		base_weight -= object.mass
	calculate_weight()
	weight_changed.emit(weight)

func calculate_weight() -> void:
	weight = base_weight
	for object in objects_on_scale:
		weight += object.mass

func on_body_weight_changed() -> void:
	calculate_weight()
	weight_changed.emit(weight)
