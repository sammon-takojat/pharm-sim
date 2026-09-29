extends RigidBody3D

var pH := 5.0

@onready var material := $Circle2.get_surface_override_material(0) as ShaderMaterial

#Fill amount clamp (0.462, 0.537)

func _ready():
	material.set_shader_parameter("Fill Amount", 0.533)
