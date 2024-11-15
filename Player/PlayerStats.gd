extends VBoxContainer

@onready var head = $HBox/Head # for when specific gear stats need to be checked
@onready var chest = $HBox2/Chest
@onready var back = $HBox2/Back
@onready var legs = $HBox3/Legs
@onready var hands = $HBox3/Hands
@onready var neck = $HBox4/Neck
@onready var ring = $HBox4/Ring
@onready var weapon: InventorySlot = $Weapon

var resistances : ItemElementType

func _ready() -> void:
	resistances = ItemElementType.new()

func show_stats():
	for i in get_child_count():
		if get_child(i).get_child_count() > 0: # gear slots only
			if get_child(i).get_child(0).get_child_count() > 0:
				print(get_child(i).get_child(0).get_child(0).data.name)

func handle_stat_change():
	resistances = ItemElementType.new()
	for i in get_child_count():
		if i != get_child_count() - 1: # excludes weapon slot
			if get_child(i).get_child(0).get_child_count() > 0: # if slot has data
				resistances.physical += get_child(i).get_child(0).get_child(0).data.gear.resistances.physical
				resistances.magical += get_child(i).get_child(0).get_child(0).data.gear.resistances.magical
				resistances.poison += get_child(i).get_child(0).get_child(0).data.gear.resistances.poison
				resistances.curse += get_child(i).get_child(0).get_child(0).data.gear.resistances.curse
	print("phys: " + str(resistances.physical) + ", mag: " + str(resistances.magical) + ", poison: " \
		+ str(resistances.poison) + ", curse: " + str(resistances.curse))

func handle_weapon_change(is_unequip : bool):
	var player_ref = get_parent().get_parent().get_parent().get_parent()
	if is_unequip: # !weapon.get_child_count() > 0
		print("weapon missing")
		var empty_item = ItemData.new()
		player_ref.change_weapon(empty_item)
	else:
		print("weapon count > 0")
		if weapon.get_child_count() > 1:
			player_ref.change_weapon(weapon.get_child(1).data)
		else:
			player_ref.change_weapon(weapon.get_child(0).data)
