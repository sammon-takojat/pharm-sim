extends TextureRect
## Script for showing instructions

var default_pos : Vector2 = self.global_position ## Default position that it resets to when closing
var default_scale : Vector2 = self.scale ## Default value for scale that it resets to when closing
var zoom := Vector2(0.05, 0.05) ## Zoom sensitivity
var max_scale := Vector2(2, 2) ## Maximum zoom
var min_scale := Vector2(0.8, 0.8) ## Minimum zoom
var sens := 0.5 ## Sensitivity for moving document
var max_pos := 1000 ## Maximum value for y so that the document always stays on screen
var min_pos := -700 ## Minimum value for y so that the document always stays on screen

## Initialize instructions to be processed always so it works when
## the scene is paused.
func _ready() -> void:
	set_process_input(false)
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	self.visible = false

## Function that handles inputs
func _input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if self.scale < max_scale:
				self.scale += zoom
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if self.scale > min_scale:
				self.scale -= zoom
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("Left_click") or Input.is_action_pressed("Right_click"):
			var new_y = self.global_position.y + event.relative.y * sens
			if new_y < max_pos and new_y > min_pos:
				self.global_position.y = new_y

## Handler runs every frame
func _process(_delta: float) -> void:
	handle_instructions()

## Call the correct function when O is pressed depending on the status of
## instructions visibility
func handle_instructions():
	if Input.is_action_just_pressed("Show_instructions"):
		if self.visible:
			hide_instructions()
		else:
			show_instructions()

## Pauses the scene and displays the instructions
func show_instructions():
	get_tree().paused = true
	self.visible = true
	set_process_input(true)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

## Hides the instructions and unpauses the scene
func hide_instructions():
	self.visible = false
	self.global_position = default_pos
	self.scale = default_scale
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	set_process_input(false)
	get_tree().paused = false
