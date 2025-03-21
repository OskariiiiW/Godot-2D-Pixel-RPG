extends Control

func _process(_delta):
	if Input.is_action_just_pressed("pause") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused == true:
		resume()

func resume():
	get_tree().paused = false
	#Engine.time_scale = 1.0
	$AnimationPlayer.play("ShowHidePauseMenu")
	
func pause():
	get_tree().paused = true
	#Engine.time_scale = 0.1
	$AnimationPlayer.play_backwards("ShowHidePauseMenu")

func _on_resume_pressed():
	resume()

func _on_settings_pressed():
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()
