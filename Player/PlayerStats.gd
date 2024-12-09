extends VBoxContainer

signal handle_weapon(weapon)
signal handle_stat(element_type, stat_type, effect_type, amount_type, amount, is_added)

@onready var head = $HBox/Head # for when specific gear stats need to be checked
@onready var chest = $HBox2/Chest
@onready var back = $HBox2/Back
@onready var legs = $HBox3/Legs
@onready var hands = $HBox3/Hands
@onready var neck = $HBox4/Neck
@onready var ring = $HBox4/Ring
@onready var weapon: InventorySlot = $Weapon

#var resistances : ItemElementType

#func _ready() -> void:
	#resistances = ItemElementType.new()

func show_stats():
	for i in get_child_count():
		if get_child(i).get_child_count() > 0: # gear slots only
			if get_child(i).get_child(0).get_child_count() > 0:
				print(get_child(i).get_child(0).get_child(0).data.name)

func handle_stat_change():
	print("handle_stat_change (depricated) (playerstats)")
	#resistances = ItemElementType.new()
	#for i in get_child_count():
	#	if i != get_child_count() - 1: # excludes weapon slot
	#		if get_child(i).get_child(0).get_child_count() > 0: # if slot has data
	#			resistances.physical += get_child(i).get_child(0).get_child(0).data.gear.resistances.physical
	#			resistances.magical += get_child(i).get_child(0).get_child(0).data.gear.resistances.magical
	#			resistances.poison += get_child(i).get_child(0).get_child(0).data.gear.resistances.poison
	#			resistances.curse += get_child(i).get_child(0).get_child(0).data.gear.resistances.curse
				#if get_child(i).get_child(0).get_child(0).data.modifiers: # gear buff/debuff
				#	pass
	#print("phys: " + str(resistances.physical) + ", mag: " + str(resistances.magical) + ", poison: " \
	#+ str(resistances.poison) + ", curse: " + str(resistances.curse))

func handle_weapon_change(is_unequip : bool):
	#var player_ref = get_parent().get_parent().get_parent().get_parent()
	if is_unequip:
		#print("weapon missing")
		var empty_item = ItemData.new()
		#player_ref.change_weapon(empty_item)
		handle_weapon.emit(empty_item)
	else:
		#print("weapon count > 0")
		if weapon.get_child_count() > 1:
			#player_ref.change_weapon(weapon.get_child(1).data)
			handle_weapon.emit(weapon.get_child(1).data)
		else:
			#player_ref.change_weapon(weapon.get_child(0).data)
			handle_weapon.emit(weapon.get_child(0).data)

func handle_gear(item : ItemData, is_equipping : bool):
	for i in item.gear.resistances.elements:
		if i.value != 0: # if amount (value) of element is more or less than 0 (skip empty)
			if is_equipping:
				handle_stat.emit(i.element + 1, 4, 1, 0, i.value, true)
				### i.element = element, 4 = res, 1 = enhance, 0 = flat, i.value = amount, true = is_added
			else:
				handle_stat.emit(i.element + 1, 4, 1, 0, i.value, false)
				### i.element = element, 4 = res, 1 = enhance, 0 = flat, i.value = amount, false = is_added
	if item.modifiers:
		for i in item.modifiers:
			if is_equipping:
				handle_stat.emit(i.element_type, i.stat_type, i.effect_type, i.amount_type, i.amount, true)
			else:
				handle_stat.emit(i.element_type, i.stat_type, i.effect_type, i.amount_type, i.amount, false)

func _on_head_handle_gear_equip(item: Variant, is_equipping: Variant) -> void:
	handle_gear(item, is_equipping)

func _on_chest_handle_gear_equip(item: Variant, is_equipping: Variant) -> void:
	handle_gear(item, is_equipping)

func _on_back_handle_gear_equip(item: Variant, is_equipping: Variant) -> void:
	handle_gear(item, is_equipping)

func _on_legs_handle_gear_equip(item: Variant, is_equipping: Variant) -> void:
	handle_gear(item, is_equipping)

func _on_hands_handle_gear_equip(item: Variant, is_equipping: Variant) -> void:
	handle_gear(item, is_equipping)

func _on_neck_handle_gear_equip(item: Variant, is_equipping: Variant) -> void:
	handle_gear(item, is_equipping)

func _on_ring_handle_gear_equip(item: Variant, is_equipping: Variant) -> void:
	handle_gear(item, is_equipping)
