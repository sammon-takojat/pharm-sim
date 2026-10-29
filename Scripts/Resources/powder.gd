extends Node

@export var powder_data: PowderData
@export var mesh: MeshInstance3D
@export var max_powder: float


func change_amount(grams: float) -> void:
	powder_data.weight = minf(max_powder, grams + powder_data.weight)
	mesh.material_override.set_shader_parameter("powder_amount", inverse_lerp(0, max_powder, powder_data.weight))
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh.material_override.set_shader_parameter("powder_amount", inverse_lerp(0, max_powder, powder_data.weight))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
