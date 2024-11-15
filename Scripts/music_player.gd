extends AudioStreamPlayer

#TODO - maybe fade out fade in when music changes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#self.play()
	pass

func set_music(music : AudioStream): #AudioStreamWAV maybe?
	stream = music
