extends RichTextLabel

var message : MessageBoxMessage

#func _ready() -> void:
#	pass # Replace with function body.

func init(_message : MessageBoxMessage) -> void:
	message = _message
	self.text = _message.message
	message.type = _message.type
