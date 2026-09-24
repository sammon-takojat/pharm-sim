extends RigidBody3D

@onready var ownMesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	body_entered.connect(changeColor)

func changeColor(body: Node3D) -> void:
	var material := ownMesh.get_active_material(0) as StandardMaterial3D
	
	if material and body.get("acidity") != null:
		var acidity: float = body.acidity
		if acidity <= 4.0:
			var t := inverse_lerp(0.0, 4.0, acidity)
			material.albedo_color = Color.RED.lerp(Color.YELLOW, t)
		elif acidity <= 7.0:
			var t := inverse_lerp(4.0, 7.0, acidity)
			material.albedo_color = Color.YELLOW.lerp(Color.GREEN, t)
		elif acidity <= 10.0:
			var t := inverse_lerp(7.0, 10.0, acidity)
			material.albedo_color = Color.GREEN.lerp(Color.BLUE, t)
		else:
			var t := inverse_lerp(10.0, 14.0, acidity)
			material.albedo_color = Color.BLUE.lerp(Color.PURPLE, t)
