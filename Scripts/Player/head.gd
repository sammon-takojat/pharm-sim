extends Node3D
## Script for player head functions i.e. mouse movement, object interactions,
## environment interactions and ui handling.

## Assign the needed nodes to variables
@onready var head = $"."
@onready var player = $".."
@onready var raycast = $Camera3D/RayCast3D
@onready var camera = $Camera3D
@onready var hand = $Camera3D/Hand

var held_object : RigidBody3D ## Picked up object
var follow_distance = 1.3 ## Distance between the picked up object and the player
var follow_speed = 8.0 ## Speed that the picked up object follows the mouse movement at
const object_rotation_damping = 100.0

## Assign ui elements to variables
@onready var reticle : ColorRect = $"../Reticle"
@onready var pickup_ui : Label = $"../PickUpUi"
@onready var use_ui : Label = $"../UseUi"
@onready var fume_hood_labels : GridContainer = $"../FumeHoodLabels"

var rotation_vector = Vector3() ## Rotation vector of the head
var sens = 0.12 ## Sensitivity of mouse movement


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	head.rotation_degrees.x = rotation_vector.x
	player.rotation_degrees.y = rotation_vector.y
	
	handle_ui()

func _physics_process(_delta):
	handle_object_holding()
	handle_inputs()

## Handles mouse movement and scroll wheel actions. Changes the rotation
## vector of the head according to mouse movement. Changes the follow distance
## of the picked up object according to scroll wheel actions.
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
		
## Function for dropping the picked up object.
func drop_held_object():
	if held_object.is_in_group("hand"):
		held_object.freeze = false
		
		var drop_point = -camera.global_basis.z * 2.0 + camera.global_position
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(camera.global_position, drop_point)
		var result = space_state.intersect_ray(query)

		if result:
			drop_point = result.position
		held_object.global_position = drop_point
		held_object.linear_velocity = Vector3.ZERO
	held_object.collision_layer = (1)
	held_object = null

## Handler for object functions. Check the state of object holding and
## calls the appropriate function depending on inputs. Also updates the position
## of the picked up object.
func handle_object_holding():
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
			if held_object == null:
				return
			held_object.global_position = hand.global_position
			held_object.global_rotation = hand.global_rotation
		else:
			target_pos = camera.global_transform.origin + (camera.global_basis * Vector3(0, 0, -follow_distance))
			var object_pos = held_object.global_transform.origin
			held_object.linear_velocity = (target_pos - object_pos) * follow_speed
			held_object.global_rotation = Vector3(0, head.global_rotation.y, 0)

## Handles interactions with the object given as a parameter.
func handle_interactions(body):
	if body is Button3D:
		body.press()
	elif body is RigidBody3D && body.is_in_group("pickable"):
		held_object = body
		held_object.collision_layer = (1 << 1)
	elif body.name == "FumeHoodStatic":
		body.get_parent().get_parent().toggle_window()
	if held_object and held_object.has_signal("drop_object"):
		if not held_object.is_connected("drop_object", _on_drop_object):
			held_object.drop_object.connect(_on_drop_object, CONNECT_ONE_SHOT)

## Function shows prompts and instructions for player.
##
## When player centers the screen on an interactable object,
## the recticle and a prompt will show up.
func handle_ui():
	use_ui.visible = false
	reticle.visible = false
	pickup_ui.visible = false
	fume_hood_labels.visible = false
	if held_object != null:
		if raycast.is_colliding():
			use_ui.visible = true
			reticle.visible = true
	elif raycast.is_colliding():
		reticle.visible = true
		if raycast.get_collider().is_in_group("pickable"):
			pickup_ui.visible = true
		elif raycast.get_collider().name == "FumeHoodStatic":
			fume_hood_labels.visible = true
			if raycast.get_collider().get_parent().get_parent().opened == true:
				fume_hood_labels.find_child("ToggleFumeHoodUse").visible = true
				if raycast.get_collider().get_parent().get_parent().up == true:
					fume_hood_labels.find_child("OpenCloseFumeHood").visible = true
				else:
					fume_hood_labels.find_child("OpenCloseFumeHood").visible = false
			else:
				fume_hood_labels.find_child("OpenCloseFumeHood").visible = true
				fume_hood_labels.find_child("ToggleFumeHoodUse").visible = false

## Calls the method "use" in the held object with the object that the player
## is looking at as a parameter.
func use_held_object():
	var object_in_los = raycast.get_collider()
	if held_object.has_method("use"):
		held_object.use(object_in_los, raycast.get_collision_point())

## Processes inputs and calls the appropriate handler function.
func handle_inputs():
	if Input.is_action_just_pressed("Use"):
		if raycast.is_colliding():
			handle_use(raycast.get_collider())

## Handler for environment interactions.
## If player interacts with fume hood the function calls the appropriate
## function in fume hoods script.
func handle_use(body):
	if body.name == "FumeHoodStatic":
		body.parent.toggle_use_mode()
		var target = body.get_parent().get_parent()
		if target.has_method("toggle_use_mode"):
			target.toggle_use_mode()
			
## A helper function that removes the held object from the hand.
func _on_drop_object():
	held_object = null
