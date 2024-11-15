class_name ActionBarSlotAction
extends TextureRect

@export var data: ItemData
#TODO - another modifier for skills - wtf does this mean?

var stack_label : Label
var stack_size

func activate(player : Player):
	if data.type == data.Type.WEAPON:
		print("weapon (ABSA)")
		# needs ref to playerstats
	elif data.type == data.Type.CONSUMABLE or data.type == data.Type.FOOD:
		for i in data.consumable.effects:
			if i.effect_type == i.EffectType.RESTORE or i.effect_type == i.EffectType.DAMAGE:
				print("restore or damage (ABSA)")
				if i.duration == 0.0:
					if i.stat_type == i.StatType.HP or i.stat_type == i.StatType.SP \
					or i.stat_type == i.StatType.MP:
						player.stats_component.handle_stat_change(i.amount, i.stat_type)
				else:
					pass
					#TODO - create buff/debuff
			elif i.effect_type == i.EffectType.ENHANCE or i.effect_type == i.EffectType.WEAKEN:
				print("enhance or weaken (ABSA)")
			else:
				print("got something else to say? (ABSA)")
		# needs ref to stat component
	elif data.type == data.Type.BOOK: # TODO - implement book class
		print("book (ABSA)")
	else: # should only be for gear
		print("gear (ABSA)")
		# needs ref to playerstats

func init(d, s: int):
	if d is ItemData:
		data = d
		stack_size = s

	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if !stack_size: #fixes null stack size in gear slots
		stack_size = 1
	stack_label = Label.new()
	self.add_child(stack_label)
	
	if data:
		texture = data.texture
		stack_label.text = str(stack_size)
		if stack_size == 1:
			stack_label.hide()

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
