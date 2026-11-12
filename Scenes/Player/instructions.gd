extends Control
## Script for showing instructions

var default_scale : Vector2 = self.scale
var zoom := Vector2(0.1, 0.1)
var max_scale := Vector2(2, 2)
var min_scale := Vector2(0.8, 0.8)

## Initialize instructions to be processed always so it works when
## the scene is paused.
func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	self.visible = false

func _input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if self.scale < max_scale:
				self.scale += zoom
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if self.scale > min_scale:
				self.scale -= zoom

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
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

## Hides the instructions and unpauses the scene
func hide_instructions():
	self.visible = false
	self.scale = default_scale
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
