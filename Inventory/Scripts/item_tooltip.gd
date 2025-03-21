extends PanelContainer

@onready var stat_node = preload("res://Inventory/Nodes/tooltip_stat.tscn")

@onready var item_name = $MarginContainer/StatsContainer/Name
@onready var description = $MarginContainer/StatsContainer/Description
@onready var value = $MarginContainer/StatsContainer/Cost

@onready var stat_value_container = $MarginContainer/StatsContainer/VBoxContainer

var isGearSlot : bool
var data : ItemData
var stack_size
var base_elements : Array[int] = [0, 1, 2, 3] # 0 = phys, 1 = mag, 2 = pois, 3 = curse
var elements : Array[Element]
var player_stats

#TODO - compare to the equipped item (failed), only show comparison if change between gear
#TODO - change tooptip border color as well? prob needs texture & 9 slice

func _ready():
	player_stats = get_tree().root.get_child(2).gui.player_stats
	item_name.text = data.name
	item_name.label_settings.set_font_color(get_rarity_color(data.tier))
	description.text = data.description
	value.text = str(data.value * stack_size)
	if data.type > 4: #gear or weapon
		# for comparison, access to playerstats needed
		var equipped_stats : Array[Element] = player_stats.check_slot_stats(check_item_slot())
		var element_value : float
		get_stat_amount() # gets elements in hovered item
		for i in base_elements:
			var exists : bool
			for x in elements:
				if x.element == i:
					exists = true
					break
			if !exists:
				for x in equipped_stats:
					if x.element == i:
						exists = true
						break
			if exists:
				var stats = stat_node.instantiate()
				if i == 0:
					stats.get_child(0).text = "Physical:"
				elif i == 1:
					stats.get_child(0).text = "Magical:"
				elif i == 2:
					stats.get_child(0).text = "Poison:"
				elif i == 3:
					stats.get_child(0).text = "Curse:"
				for x in elements:
					if x.element == i:
						element_value = x.value
						stats.get_child(1).text = str(x.value)
				if equipped_stats.size() > 0:
					for x in equipped_stats:
						if x.element == i:
							if x.value < element_value:
								stats.get_child(2).set("theme_override_colors/font_color","Green")
								stats.get_child(2).text = "+" + str(element_value - x.value)
							elif x.value > element_value:
								stats.get_child(2).set("theme_override_colors/font_color","Red")
								stats.get_child(2).text = str(element_value - x.value)
							else:
								stats.get_child(2).text = ""
				else:
					stats.get_child(2).text = ""
				stat_value_container.add_child(stats)


		#for i in elements:
		#	var stats = stat_node.instantiate()
		#	if i.element == 0:
		#		stats.get_child(0).text = "Physical:"
		#	elif i.element == 1:
		#		stats.get_child(0).text = "Magical:"
		#	elif i.element == 2:
		#		stats.get_child(0).text = "Poison:"
		#	elif i.element == 3:
		#		stats.get_child(0).text = "Curse:"
		#	stats.get_child(1).text = str(i.value)
		#	if equipped_stats.size() > 0:
		#		for x in equipped_stats:
		#			if x.element == i.element:
		#				if x.value < i.value:
		#					stats.get_child(2).set("theme_override_colors/font_color","Green")
		#					stats.get_child(2).text = "+" + str(i.value - x.value)
		#				elif x.value > i.value:
		#					stats.get_child(2).set("theme_override_colors/font_color","Red")
		#					stats.get_child(2).text = str(i.value - x.value)
		#				else:
							#stats.get_child(2).label_settings.set_font_color("White")
		#					stats.get_child(2).text = ""
		#	else:
				#stats.get_child(2).label_settings.set_font_color("White")
		#		stats.get_child(2).text = ""
		#	stat_value_container.add_child(stats)


		#for i in elements: # adds element if element in elements but not in equipped
		#	for x in equipped_stats:
		#		if i.element != x.element:
		#			var stats = stat_node.instantiate()
		#			if i.element == 0:
		#				stats.get_child(0).text = "Physical"
		#			elif i.element == 1:
		#				stats.get_child(0).text = "Magical"
		#			elif i.element == 2:
		#				stats.get_child(0).text = "Poison"
		#			elif i.element == 3:
		#				stats.get_child(0).text = "Curse"
		#			stats.get_child(1).text = str(i.value)
		#			stats.get_child(2).set("theme_override_colors/font_color","Green")
		#			stats.get_child(2).text = "+" + str(i.value)
		#			stat_value_container.add_child(stats)
		#for i in equipped_stats:
		#	for x in elements:
		#		if i.element != x.element:
		#			var stats = stat_node.instantiate()
		#			if i.element == 0:
		#				stats.get_child(0).text = "Physical"
		#			elif i.element == 1:
		#				stats.get_child(0).text = "Magical"
		#			elif i.element == 2:
		#				stats.get_child(0).text = "Poison"
		#			elif i.element == 3:
		#				stats.get_child(0).text = "Curse"
		#			stats.get_child(1).text = str(i.value)
		#			stats.get_child(2).set("theme_override_colors/font_color","Red")
		#			stats.get_child(2).text = str(0 - i.value)
		#			stat_value_container.add_child(stats)

func init(_data : ItemData, _stack_size : int, _isGearSlot : bool):
	data = _data
	stack_size = _stack_size
	isGearSlot = _isGearSlot

func get_rarity_color(tier : int):
	if tier == 0: #common
		return "Gray"
	elif tier == 1: #uncommon
		return "Light_green"
	elif tier == 2: #rare
		return "Powder_blue"
	elif tier == 3: #epic
		return "Violet"
	elif tier == 4: #legendary
		return "Gold"
	elif tier == 5: #mythic
		return "Purple"
	elif tier == 6: #godly
		return "Deep_sky_blue"
	elif tier == 7: #demonic
		return "Crimson"

func get_stat_amount():
	elements.clear()
	if data.gear:
		if data.gear.resistances:
			for i in data.gear.resistances:
				if i.value != 0:
					elements.append(i)
	elif data.weapon:
		if !data.weapon.is_ranged:
			for i in data.weapon.damage:
				if i.value != 0:
					elements.append(i)
		else:
			for i in data.weapon.projectile.damage:
				if i.value != 0:
					elements.append(i)

func check_item_slot():
	if data.type == 5: # head
		return 0
	elif data.type == 6: # neck
		return 5
	elif data.type == 7: # back
		return 2
	elif data.type == 8: # chest
		return 1
	elif data.type == 9: # hands
		return 4
	elif data.type == 10: # ring
		return 6
	elif data.type == 11: # legs
		return 3
	elif data.type == 13: # weapon
		return 7
	# head = 0, chest = 1, back = 2, legs = 3, hands = 4, neck = 5, ring = 6, weapon = 7
	# feet unused lolz
