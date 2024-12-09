extends TextureRect

class_name Buff

signal handle_buff(element_type, stat_type, effect_type, amount_type, amount, is_added)

@onready var label: Label = $Label
@onready var timer: Timer = $Timer

var effect : ConsumableEffect
var time_left : float

func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	if effect:
		time_left = effect.duration
		handle_time_label()
		texture = effect.icon
	else:
		print("there is a buff with no effect (buff)")

func init(data : ConsumableEffect):
	effect = data

func handle_remove():
	handle_buff.emit(effect.element_type, effect.stat_type, effect.effect_type\
	, effect.amount_type, effect.amount, false)
	visible = false

func handle_time_label():
	if time_left > 60:
			if time_left / 60 > 60:
				var hours = roundf(time_left / 360)
				label.text = str(hours) + "h"
			else:
				var minutes = time_left / 60
				label.text = str(minutes) + "m"
	else:
		label.text = str(time_left)

func _on_timer_timeout(): # 1 sec = 1.0
	time_left -= timer.wait_time
	if time_left <= 0:
		handle_remove()
	handle_time_label()
