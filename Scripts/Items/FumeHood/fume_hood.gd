extends Node3D

var opened = false
var up = false

func toggle_window():
	if $AnimationPlayer.current_animation != "open" and $AnimationPlayer.current_animation != "halfwaydown":
		if !opened:
			$AnimationPlayer.play("open")
			opened = !opened
			up = !up
		elif opened:
			if up:
				$AnimationPlayer.play_backwards("open")
				opened = !opened
				up = !up

func toggle_use_mode():
	if opened:
		if $AnimationPlayer.current_animation != "open" and $AnimationPlayer.current_animation != "halfwaydown":
			if up:
				$AnimationPlayer.play("halfwaydown")
			elif !up:
				$AnimationPlayer.play_backwards("halfwaydown")
			up = !up
