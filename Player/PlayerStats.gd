extends VBoxContainer

signal handle_weapon(weapon)
signal handle_stat(element_type, stat_type, effect_type, amount_type, amount, is_added)

@onready var head = $Head/Head # for when specific gear stats need to be checked
@onready var chest = $ChestBack/Chest
@onready var back = $ChestBack/Back
@onready var legs = $LegsHands/Legs
@onready var hands = $LegsHands/Hands
@onready var neck = $NeckRing/Neck
@onready var ring = $NeckRing/Ring
@onready var weapon: InventorySlot = $Weapon

func check_slot_stats(slot : int):
	if slot == 0:
		if head.get_child_count() > 0:
			return head.get_child(0).data.gear.resistances
	elif slot == 1:
		if chest.get_child_count() > 0:
			return chest.get_child(0).data.gear.resistances
	elif slot == 2:
		if back.get_child_count() > 0:
			return back.get_child(0).data.gear.resistances
	elif slot == 3:
		if legs.get_child_count() > 0:
			return legs.get_child(0).data.gear.resistances
	elif slot == 4:
		if hands.get_child_count() > 0:
			return hands.get_child(0).data.gear.resistances
	elif slot == 5:
		if neck.get_child_count() > 0:
			return neck.get_child(0).data.gear.resistances
	elif slot == 6:
		if ring.get_child_count() > 0:
			return ring.get_child(0).data.gear.resistances
	elif slot == 7:
		if weapon.get_child_count() > 0:
			if weapon.get_child(0).data.weapon.is_ranged:
				return weapon.get_child(0).data.weapon.projectile.damage
			else:
				return weapon.get_child(0).data.weapon.damage
	var empty_array : Array[Element]
	return empty_array

func show_stats():
	for i in get_child_count():
		if get_child(i).get_child_count() > 0: # gear slots only
			if get_child(i).get_child(0).get_child_count() > 0:
				print(get_child(i).get_child(0).get_child(0).data.name)

func handle_weapon_change(is_unequip : bool):
	if is_unequip:
		var empty_item = ItemData.new()
		handle_weapon.emit(empty_item)
	else:
		if weapon.get_child_count() > 1:
			handle_weapon.emit(weapon.get_child(1).data)
		else:
			handle_weapon.emit(weapon.get_child(0).data)

func handle_gear(item : ItemData, is_equipping : bool):
	for i in item.gear.resistances:
		if i.value != 0: # if amount (value) of element is more or less than 0 (skip empty)
			if is_equipping:
				handle_stat.emit(i.element + 1, 4, 1, 0, i.value, true)
				### i.element = element, 4 = res, 1 = enhance, 0 = flat, i.value = amount, true = is_added
			else:
				handle_stat.emit(i.element + 1, 4, 1, 0, i.value, false)
				### i.element = element, 4 = res, 1 = enhance, 0 = flat, i.value = amount, false = is_added
	if item.effects.size() > 0:
		for i in item.effects:
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
