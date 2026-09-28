extends RigidBody3D

@onready var ownMesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	var material := ownMesh.get_active_material(0)
	if material:
		ownMesh.set_surface_override_material(0, material.duplicate())
	self.body_entered.connect(changeColor)

func changeColor(body: Node3D) -> void:
	var material := ownMesh.get_active_material(0) as StandardMaterial3D
	
	if material and body.get("pH") != null:
		var pH: float = body.pH
		if pH <= 4.0:
			var t := inverse_lerp(0.0, 4.0, pH)
			material.albedo_color = Color.RED.lerp(Color.YELLOW, t)
		elif pH <= 7.0:
			var t := inverse_lerp(4.0, 7.0, pH)
			material.albedo_color = Color.YELLOW.lerp(Color.GREEN, t)
		elif pH <= 10.0:
			var t := inverse_lerp(7.0, 10.0, pH)
			material.albedo_color = Color.GREEN.lerp(Color.BLUE, t)
		else:
			var t := inverse_lerp(10.0, 14.0, pH)
			material.albedo_color = Color.BLUE.lerp(Color.PURPLE, t)
