extends Node3D


@onready var head = $"."
@onready var player = $".."
@onready var raycast = $Camera3D/RayCast3D
@onready var camera = $Camera3D
@onready var hand = $Camera3D/Hand
@onready var drop_point = $Camera3D/DropPoint

var held_object : RigidBody3D
var follow_distance = 1.3
var follow_speed = 8.0
const object_rotation_damping = 100.0

@onready var reticle : ColorRect = $"../Reticle"
@onready var pickup_ui : Label = $"../PickUpUi"
@onready var use_ui : Label = $"../UseUi"



var rotation_vector = Vector3()
var sens = 0.12


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	head.rotation_degrees.x = rotation_vector.x
	player.rotation_degrees.y = rotation_vector.y
	
	handle_ui()

func _physics_process(delta):
	handle_object_holding(delta)


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion:
		rotation_vector.y -= (event.relative.x * sens)
		rotation_vector.x -= (event.relative.y * sens)
		rotation_vector.x = clamp(rotation_vector.x,-90,90)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			follow_distance = min(follow_distance + 0.1 , 5.0)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			follow_distance = max(follow_distance - 0.1, 0.7)
		

func drop_held_object():
	if held_object.is_in_group("hand"):
		held_object.global_position = drop_point.global_position
		held_object.linear_velocity = Vector3.ZERO
	held_object = null

func handle_object_holding(delta):
	if Input.is_action_just_pressed("Interact"):
		if held_object != null:
			drop_held_object()
			follow_distance = 1.3
			follow_speed = 8.0
		elif raycast.is_colliding():
			handle_interactions(raycast.get_collider())
	
	if held_object != null:
		var target_pos : Vector3
		if held_object.is_in_group("hand"):
			if Input.is_action_just_pressed("Use"):
				use_held_object()
			held_object.global_position = hand.global_position
			held_object.global_rotation = hand.global_rotation
		else:
			target_pos = camera.global_transform.origin + (camera.global_basis * Vector3(0, 0, -follow_distance))
			var object_pos = held_object.global_transform.origin
			held_object.linear_velocity = (target_pos - object_pos) * follow_speed
			held_object.angular_velocity = held_object.angular_velocity.move_toward(Vector3.ZERO, delta * object_rotation_damping)

func handle_interactions(body):
	if body is Button3D:
		body.emit_signal("pressed")
	elif body is RigidBody3D && body.is_in_group("pickable"):
		held_object = body

func handle_ui():
	if held_object != null:
		if raycast.is_colliding():
			use_ui.visible = true
		else:
			use_ui.visible = false
		reticle.visible = false
		pickup_ui.visible = false	
	elif raycast.is_colliding():
		reticle.visible = true
		if raycast.get_collider().is_in_group("pickable"):
			pickup_ui.visible = true
	else:
		use_ui.visible = false
		reticle.visible = false
		pickup_ui.visible = false

func use_held_object():
	var object_in_los = raycast.get_collider()
	if held_object.has_method("use"):
		held_object.use(object_in_los)
