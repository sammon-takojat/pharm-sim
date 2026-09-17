extends Node3D


@onready var head = $"."
@onready var player = $".."
@onready var raycast = $Camera3D/RayCast3D
@onready var hand = $Hand

@onready var reticle : ColorRect = $"../Reticle"
@onready var pickup_ui : Label = $"../PickUpUi"

var rotation_vector = Vector3()
var sens = 0.12
var is_picked_up = false

# Called when the node enters the scene tree for the first time.

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	head.rotation_degrees.x = rotation_vector.x
	player.rotation_degrees.y = rotation_vector.y
	
	pickup_ui.visible = false
	
	if raycast.is_colliding():
		reticle.visible = true
		var object = raycast.get_collider()
		
		if object.is_in_group("pickable"):
			pickup_ui.visible = true
			
			if Input.is_action_pressed("Interact"):
				object.global_position = hand.global_position
				object.global_rotation = hand.global_rotation
				
				pickup_ui.visible = false
	else:
		reticle.visible = false


func _input(event):
	if event is InputEventMouseMotion:
		rotation_vector.y -= (event.relative.x * sens)
		rotation_vector.x -= (event.relative.y * sens)
		rotation_vector.x = clamp(rotation_vector.x,-90,90)
