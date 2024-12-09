extends Control

signal handle_buff(element_type, stat_type, effect_type, amount_type, amount, is_added)

var buff_node = preload("res://Nodes/UI/Buffs_Debuffs/buff.tscn")

@onready var v_box: VBoxContainer = $Margin/VBox

var buffs : Array[Buff]

# BUFFS TO BE IMPLEMENTED IN STATSCOMPONENT
var speed : float = 0.0 			# enhance / weaken - flat
var speed_percent : float = 0.0 	# enhance / weaken - %

#TODO - when adding buffs, sort the array so longest is first [0]
#TODO - tooltip when hovering over buff
#TODO - better buff alignment if many (2 or more rows instead of 1)

func _ready() -> void:
	for i in buffs:
		var new_buff = buff_node.instantiate()
		new_buff.init(i.effect)
		v_box.add_child(new_buff)

func add_buff(effect : ConsumableEffect):
	var can_be_added : bool = true
	for i in buffs:
		if i.effect == effect and !effect.can_stack:
			can_be_added = false
	if can_be_added:
		var new_buff = buff_node.instantiate()
		new_buff.init(effect)
		handle_buff.emit(effect.element_type, effect.stat_type, effect.effect_type\
		, effect.amount_type, effect.amount, true)
		new_buff.connect("handle_buff", _on_buff_handle_buff)
		buffs.append(new_buff)
		v_box.add_child(new_buff)
	else:
		print("unique buff already exists")

func remove_buff(element_type: Variant, stat_type: Variant, effect_type: Variant, \
amount_type: Variant, amount: Variant, is_added: Variant) -> void:
	for i in buffs.size():
		if buffs[i].effect.element_type == element_type and buffs[i].effect.stat_type == stat_type \
		and buffs[i].effect.effect_type == effect_type and buffs[i].effect.amount_type == amount_type \
		and buffs[i].effect.amount == amount:
			handle_buff.emit(element_type, stat_type, effect_type, amount_type, amount, is_added)
			var to_free = buffs[i]
			buffs.pop_at(i)
			to_free.queue_free()
			break
		# wtf gonna happen when multiple stacking buffs? - wtf you mean?

func _on_buff_handle_buff(element_type: Variant, stat_type: Variant, effect_type: Variant, \
amount_type: Variant, amount: Variant, is_added: Variant) -> void:
	if !is_added:
		remove_buff(element_type, stat_type, effect_type, amount_type, amount, is_added)
