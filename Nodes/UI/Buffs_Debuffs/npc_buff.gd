extends Timer

class_name NPCBuff

signal handle_buff(element_type, stat_type, effect_type, amount_type, amount, is_added)

@onready var timer: NPCBuff = $"."

var effect : ConsumableEffect

func _ready() -> void:
	timer.wait_time = effect.duration

func init(data : ConsumableEffect):
	print("npc buff added (npc buff)")
	effect = data

func handle_remove():
	print("npc buff removed (npc buff)")
	handle_buff.emit(effect.element_type, effect.stat_type, effect.effect_type\
	, effect.amount_type, effect.amount, false)

func _on_timeout() -> void: # 1 sec = 1.0
	handle_remove()
