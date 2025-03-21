class_name ActionBarSlotAction
extends TextureRect

@export var data : Resource

#TODO - another modifier for skills - wtf does this mean?
#TODO - remove data from slot if original item lost

var stack_label : Label
var stack_size

func activate(player : Player): # when pressed on action bar
	if data is ItemData:
		if data.type == data.Type.CONSUMABLE or data.type == data.Type.FOOD:
			for i in data.effects:
				if i.duration != 0.0:
					if player.buff_list:
						player.buff_list.add_buff(i)
					else:
						print("no buff list (ABSA)")
				else: # zero duration buffs (permanent)
					if i.effect_type == i.EffectType.RESTORE:
						print("0 duration restore (ABSA)")
						if i.stat_type == i.StatType.HP or i.stat_type == i.StatType.SP \
						or i.stat_type == i.StatType.MP:
							if i.amount_type == i.AmountType.FLATVALUE:
								player.stats_component.handle_stat_change(i.amount, true, i.stat_type, false)
							else:
								player.stats_component.handle_stat_change(i.amount, false, i.stat_type, false)
					else:
						player.stats_component.handle_buff(i.element, i.stat_type, i.effect_type\
						, i.amount_type, i.amount, true)
						print("permabuff added")
			stack_size -= 1
			stack_label.text = str(stack_size)
			player.inventory_data.remove_one(data)
			if stack_size == 0:
				self.queue_free()
		elif data.type == data.Type.BOOK: # TODO - implement book class
			print("book (ABSA)")
		elif data.type == data.Type.WEAPON:
			print("weapon (ABSA)")
			# player.player_stats_node
		else: # should only be for gear
			print("gear (ABSA)")
			# needs ref to playerstats
	elif data is ActionSkill:
		player.use_skill(data)
		#skill buff adding not handled here, bc only self buffs would work

func init(_data, stack: int):
	stack_label = Label.new()
	if _data is ItemData:
		data = _data
		stack_size = stack
		if !stack_size: #fixes null stack size in gear slots
			stack_size = 1
		stack_label.text = str(stack_size)
		if stack_size == 1:
			stack_label.hide()
	elif _data is ActionSkill:
		data = _data
		stack_size = 1
		stack_label.text = str(data.cost)
		if data.cost_type == data.CostType.HP:
			stack_label.set("theme_override_colors/font_color","Red")
		elif data.cost_type == data.CostType.SP:
			stack_label.set("theme_override_colors/font_color","Green")
		elif data.cost_type == data.CostType.MP:
			stack_label.set("theme_override_colors/font_color","Blue")
	self.add_child(stack_label)
	texture = data.icon
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func update_stack():
	stack_label.text = str(stack_size)

	if stack_size > 1:
		stack_label.show()
	else:
		print("stack size: " + str(stack_size) + " (for seeing if neg stack) (ABSA)")
		stack_label.hide()

func _get_drag_data(at_position):
	if data: # disables dragging with empty slots - might be redundant now
		set_drag_preview(make_drag_preview(at_position))
		return self

func make_drag_preview(at_position):
	var t := TextureRect.new()
	t.texture = texture
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = size
	t.modulate.a = 0.5
	t.position = Vector2(-at_position)

	var c := Control.new()
	c.add_child(t)
	return c
