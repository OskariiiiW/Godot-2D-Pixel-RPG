extends RichTextLabel

var message : MessageBoxMessage

func init(_message : MessageBoxMessage) -> void:
	message = _message
	self.text = _message.message
	message.type = _message.type
