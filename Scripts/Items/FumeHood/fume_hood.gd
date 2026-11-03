extends Node3D
## Script for fume hood functions. Plays the appropriate
## animation when the player interacts with the object.

@onready var animation_player : AnimationPlayer = $AnimationPlayer

var opened = false ## State of the windows' current position (opened or closed)
var up = false ## Variant to track windows' use mode off or on

## Toggles the fume hood window between opened and closed
## positions.
##
## Plays the "open" animation if the window is closed and
## reverses the animation if it is open. Also checks that
## the window is not in use mode when closing it
func toggle_window() -> void:
	if animation_player.current_animation != "open" and animation_player.current_animation != "halfwaydown":
		if !opened:
			animation_player.play("open")
			opened = !opened
			up = !up
		elif opened:
			if up:
				animation_player.play_backwards("open")
				opened = !opened
				up = !up


## Toggles the fume hood between its raised position and halfway lowered
## use position.
##
## Plays the "halfwaydown" animation when lowering it from open state and
## reverses it when lifting the window back up. The function can only be
## called when the window is open.
func toggle_use_mode() -> void:
	if opened:
		if animation_player.current_animation != "open" and animation_player.current_animation != "halfwaydown":
			if up:
				animation_player.play("halfwaydown")
			elif !up:
				animation_player.play_backwards("halfwaydown")
			up = !up
