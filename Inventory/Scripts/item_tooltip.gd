extends PanelContainer

var isGearSlot : bool
var data : ItemData
var stack_size
var elements_name = ["physical", "magical", "poison", "curse"]
var elements : Array[float]

@onready var stat_node = preload("res://Inventory/Nodes/tooltip_stat.tscn")

@onready var item_name = $MarginContainer/StatsContainer/Name
@onready var description = $MarginContainer/StatsContainer/Description
@onready var value = $MarginContainer/StatsContainer/Cost

@onready var stat_value_container = $MarginContainer/StatsContainer/VBoxContainer
#@onready var player_stats = $GUI/PlayerInventory/VBoxContainer # for accessing player stats - not usable

#TODO - compare to the equipped item (failed), only show comparison if change between gear
#TODO - change tooptip border color as well? prob needs texture & 9 slice
#TODO - maybe less spaghetti code?

func _ready():
	item_name.text = data.name
	item_name.label_settings.set_font_color(get_rarity_color(data.tier))
	description.text = data.description
	value.text = str(data.value * stack_size)
	if data.type > 4: #gear or weapon
		get_stat_amount()
		#if data.type == 13: #weapon - might be useful again with weapon stats
		var index = -1
		for i in elements:
			index += 1
			if i != 0:
				var stats = stat_node.instantiate()
				stats.get_child(0).text = elements_name[index].to_upper() #stat name
				stats.get_child(1).text = str(i) #stat value
				if !isGearSlot: # need to get current gear slot data
					#if data.type == 5: # head
						#if i < player_stats.head.get_child(0).data.gear.resistances.physical:
						#	stats.get_child(2).label_settings.set_font_color("Red")
						#elif i > player_stats.head.get_child(0).data.gear.resistances.physical:
						#	stats.get_child(2).label_settings.set_font_color("Green")
						#stats.get_child(2).text = str(i - player_stats.head.get_child(0).data.gear.resistances.physical)
					stats.get_child(2).text = "" #stat difference
				stat_value_container.add_child(stats)

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

func get_stat_amount(): #dunno how to use for loop with arrays
	elements.clear()
	if data.gear:
		if data.gear.resistances:
			elements.append(data.gear.resistances.physical)
			elements.append(data.gear.resistances.magical)
			elements.append(data.gear.resistances.poison)
			elements.append(data.gear.resistances.curse)
	else:
		if !data.weapon.is_ranged:
			elements.append(data.weapon.damage.physical)
			elements.append(data.weapon.damage.magical)
			elements.append(data.weapon.damage.poison)
			elements.append(data.weapon.damage.curse)
		else:
			elements.append(data.weapon.projectile.damage.physical)
			elements.append(data.weapon.projectile.damage.magical)
			elements.append(data.weapon.projectile.damage.poison)
			elements.append(data.weapon.projectile.damage.curse)
