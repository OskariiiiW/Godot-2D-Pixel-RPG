extends CanvasLayer

func change_scene(new_scene : String):
	$AnimationPlayer.play("dissolve")
	#await ($AnimationPlayer, "animation_finished")
	await get_tree().create_timer(0.5).timeout #TODO - actually show some effort
	get_tree().change_scene_to_file(new_scene) 
	$AnimationPlayer.play_backwards("dissolve")
