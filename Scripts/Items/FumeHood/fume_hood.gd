extends Node3D

var opened = false

func toggle_window():
	if $AnimationPlayer.current_animation != "open" and $AnimationPlayer.current_animation != "close":
		if !opened:
			$AnimationPlayer.play("open")
		elif opened:
			$AnimationPlayer.play("close")
		opened = !opened
