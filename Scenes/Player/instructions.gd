extends Control
## Script for showing instructions

## Initialize instructions to be processed always so it works when
## the scene is paused.
func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	self.visible = false

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
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
