extends CanvasLayer

@onready var popin_text: Label = $Control/Panel/Margin/PopInText

var popin_content_queue : Array[String]
var popping : bool

func _physics_process(_delta):
	if popin_content_queue.size() > 0 and !popping:
		popping = true
		print("popin queue: " + str(popin_content_queue.size()))
		popin_text.text = popin_content_queue[0]
		$AnimationPlayer.play("popIn")
		await get_tree().create_timer(1).timeout
		$AnimationPlayer.play_backwards("popIn")
		await get_tree().create_timer(0.5).timeout # bad way to wait until animation finished?
		popin_content_queue.remove_at(0)
		popping = false

func queue_popup(message : String) -> void:
	popin_content_queue.append(message)
