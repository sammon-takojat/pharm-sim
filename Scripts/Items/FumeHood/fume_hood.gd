extends Node3D

var opened = false
var up = false

@export var animation_player : AnimationPlayer

func toggle_window():
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

func toggle_use_mode():
	if opened:
		if animation_player.current_animation != "open" and animation_player.current_animation != "halfwaydown":
			if up:
				animation_player.play("halfwaydown")
			elif !up:
				animation_player.play_backwards("halfwaydown")
			up = !up
