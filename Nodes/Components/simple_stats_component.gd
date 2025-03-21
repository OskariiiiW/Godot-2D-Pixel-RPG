extends Node2D

class_name SimpleStatsComponent

@export var MAX_HEALTH : float = 1.0

@export var resistances : Array[Element]

@export var loot_component : LootComponent

var health : float

func _ready():
	health = MAX_HEALTH
	if !resistances:
		print("no resistances set on " + get_parent().name +  " (SimpleStatsComponent)")

func handle_stat_change(amount : float):
	health += amount
	if health <= 0:
		handle_death()

func handle_death():
	if loot_component:
		var inst = loot_component.loot_base_node.instantiate()
		inst.get_child(2).item.item_data = loot_component.loot
		inst.get_child(2).item.quantity = loot_component.loot_quantity
		await get_tree().process_frame # stops deterred() warnings
		owner.get_parent().add_child(inst)
		inst.transform = owner.global_transform
		owner.queue_free()
	else:
		print("no loot component (stats component)")
		owner.queue_free()

func damage(attack : Array[Element]):
	var total_damage = calculate_damage(attack)
	handle_stat_change(-total_damage)

func calculate_damage(inc_damage : Array[Element]):
	var total_damage : Array[float]
	var final_damage : float = 0
	for i in inc_damage:
		for x in resistances:
			if i.element == x.element: ### i = dmg, x = res
				if x.value > 0:
					var reduction = x.value / i.value
					total_damage.append(i.value / reduction)
				elif x.value < 0:
					total_damage.append(i.value + (x.value / -2))
				else: # == 0
					total_damage.append(i.value)
				break

	for i in total_damage:
		if i < 0:
			i = 0
		final_damage += i
	print("Total damage: " + str(final_damage) + " (simple_stats_component)")
	return final_damage
