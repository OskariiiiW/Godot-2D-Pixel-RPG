extends Node2D

class_name StatsComponent

enum BodyType {UNKNOWN, HUMANOID, UNDEAD, DEMON, INSECT, BEAST, ELEMENTAL}

@export var character_name : String
@export var faction_name : String
@export var body : BodyType
@export var race : Race

@export var is_unique : bool # if can be added to relation dictionary - no, they should be there
@export var godmode_enabled : bool # for debug & testing (maybe for essencial npc)

var MAX_HEALTH_BUFF : float = 0.0 		# flat
var HEALTH_REGEN_BUFF : float = 0.1 	# %
var health_skill_cost : float = 0.0 	# %

var MAX_STAMINA_BUFF : float = 0.0		# flat
var STAMINA_REGEN_BUFF : float = 0.1 	# %
var stamina_skill_cost : float = 0.0 	# %

var MAX_MAGICKA_BUFF : float = 0.0 		# flat
var MAGICKA_REGEN_BUFF : float = 0.1 	# %
var magicka_skill_cost : float = 0.0 	# %

var speed : float = 0			# flat
var speed_percent : float = 0	# %

# what about stats in Stats????

@export var resistances : Array[Element] 				# combined value of all res
@export var resistances_buff : Array[Element] 			# flat
@export var resistances_percent_buff : Array[Element] 	# %

@export var dmg : Array[Element]				# combined value of all dmg
@export var dmg_buff : Array[Element]			# flat
@export var dmg_percent_buff : Array[Element]	# %

@export var has_advanced_stats : bool # if char can get bonus from gear - atm only player

@export var stats : Stats
@export var stat_buffs : Stats
@export var skills : Array[Skill] # skills from race?

@export var loot_component : LootComponent

var stat_bars_node
var health : float
var stamina : float
var magicka : float

#TODO - fame, karma and intimidation
#TODO - make popups player only - not sure if they even can happen to npc anymore
#TODO - movement debuff if stam reaches 0??
#TODO - "damage" hp bar
#TODO - bars grow longer if there is a buff that increases max values?

func _ready():
	if !resistances:
		print("no resistances set (stats_component) on " + character_name)
	if !race:
		print("no race on " + character_name)
		race = Race.new()
		race.add_base_resistances()

	health = MAX_HEALTH_BUFF + race.BASE_MAX_HEALTH # TODO - load from file
	stamina = MAX_STAMINA_BUFF + race.BASE_MAX_STAMINA # -ll-
	magicka = MAX_MAGICKA_BUFF + race.BASE_MAX_MAGICKA # -ll-

func handle_buff(element, stat, effect_type, amount_type, amount, is_added):
	if element == 0:		# NO ELEMENT
		if stat == 0: 			# HP
			if effect_type == 1: 		# HP ENHANCE FLAT
				if is_added:
					MAX_HEALTH_BUFF += amount # array of floats could make code shorter
				else:
					MAX_HEALTH_BUFF -= amount
					if health > MAX_HEALTH_BUFF + race.BASE_MAX_HEALTH:
						health = MAX_HEALTH_BUFF + race.BASE_MAX_HEALTH
				stat_bars_node.change_max_value(MAX_HEALTH_BUFF + race.BASE_MAX_HEALTH, stat)
			elif effect_type == 2: 		# HP REGEN (ONLY %)
				if is_added:
					HEALTH_REGEN_BUFF += amount
				else:
					HEALTH_REGEN_BUFF -= amount
			elif effect_type == 3: 		# HP SKILLCOST (ONLY %)
				if is_added:
					health_skill_cost += amount
				else:
					health_skill_cost -= amount
		elif stat == 1:			# SP
			if effect_type == 1: 		# SP ENHANCE FLAT
				if is_added:
					MAX_STAMINA_BUFF += amount
				else:
					MAX_STAMINA_BUFF -= amount
					if stamina > MAX_STAMINA_BUFF + race.BASE_MAX_STAMINA:
						stamina = MAX_STAMINA_BUFF + race.BASE_MAX_STAMINA
				stat_bars_node.change_max_value(MAX_STAMINA_BUFF + race.BASE_MAX_STAMINA, stat)
			elif effect_type == 2: 		# SP REGEN (ONLY %)
				if is_added:
					STAMINA_REGEN_BUFF += amount
				else:
					STAMINA_REGEN_BUFF -= amount
			elif effect_type == 3: 		# SP SKILLCOST (ONLY %)
				if is_added:
					stamina_skill_cost += amount
				else:
					stamina_skill_cost -= amount
		elif stat == 2:			# MP
			if effect_type == 1: 		# MP ENHANCE FLAT
				if is_added:
					MAX_MAGICKA_BUFF += amount
				else:
					MAX_MAGICKA_BUFF -= amount
					if magicka > MAX_MAGICKA_BUFF + race.BASE_MAX_MAGICKA:
						magicka = MAX_MAGICKA_BUFF + race.BASE_MAX_MAGICKA
				stat_bars_node.change_max_value(MAX_MAGICKA_BUFF + race.BASE_MAX_MAGICKA, stat)
			elif effect_type == 2: 		# MP REGEN (ONLY %)
				if is_added:
					MAGICKA_REGEN_BUFF += amount
				else:
					MAGICKA_REGEN_BUFF -= amount
			elif effect_type == 3: 		# MP SKILLCOST (ONLY %)
				if is_added:
					magicka_skill_cost += amount
				else:
					magicka_skill_cost -= amount
		elif stat == 3: # dmg - not used bc "true" dmg not good imo - could also be replaced with a new element
			print("remember to add an element to dmg buff (stats component)") #dmg or res buff missing element
		elif stat == 4: # res - not used bc "true" dmg res not good imo
			print("remember to add an element to res buff (stats component)") #dmg or res buff missing element
		elif stat == 5:			# SPEED
			if effect_type == 1:		# ENHANCE
				if amount_type == 0:	# FLAT
					if is_added:
						get_parent().speed_buff += amount
					else:
						get_parent().speed_buff -= amount
				else:					# %
					if is_added:
						get_parent().speed_mult += amount
					else:
						get_parent().speed_mult -= amount
	else:					# ELEMENTS
		if stat == 3:			# DMG
			if effect_type == 1:		# ENHANCE
				if amount_type == 0:	# FLAT
					if is_added:
						dmg_buff[element - 1].value += amount
					else:
						dmg_buff[element - 1].value -= amount
				else:					# %
					if is_added:
						dmg_percent_buff[element - 1].value += amount
					else:
						dmg_percent_buff[element - 1].value -= amount
				update_dmg(element - 1)
		elif stat == 4:			# RESISTANCE
			if effect_type == 1:		# ENHANCE
				if amount_type == 0:	# FLAT
					if is_added:
						resistances_buff[element - 1].value += amount
					else:
						resistances_buff[element - 1].value -= amount
				else:					# %
					if is_added:
						resistances_percent_buff[element - 1].value += amount
					else:
						resistances_percent_buff[element - 1].value -= amount
				update_resistances(element - 1)
	update_stat_bars()

func update_resistances(e : int): # PROBLEM - base resistances rarely change bc gear handled as buffs
	resistances[e].value = race.resistances[e].value		# RACE +=
	resistances[e].value += resistances_buff[e].value 	# FLAT
	resistances[e].value += resistances[e].value \
	* (resistances_percent_buff[e].value)							# PERCENT
	print("TOTAL RES; physical: " + str(resistances[0].value) \
	+ " magical: " + str(resistances[1].value) \
	+ " poison: " + str(resistances[2].value) \
	+ " curse: " + str(resistances[3].value))

func update_dmg(element : int):
	dmg[element].value = dmg_buff[element].value						# FLAT
	dmg[element].value += resistances[element].value \
	* (resistances_percent_buff[element].value)							# PERCENT
	if get_parent().has_method("update_weapon_dmg"):
		get_parent().update_weapon_dmg()
	else:
		print(character_name +" has no update_weapon_dmg (stats_component)")

func handle_stat_change(amount : float, is_flat : bool, type : int, is_from_skill : bool):
	if type == 0: # hp
		if is_flat:
			if is_from_skill:
				health += amount + (amount * health_skill_cost) # test if quik math correct?
			else:
				health += amount
		else:
			if is_from_skill:
				health += health * amount + (amount * health_skill_cost) # test if quik math correct?
			else:
				health += health * amount
		if health > MAX_HEALTH_BUFF + race.BASE_MAX_HEALTH:
			health = MAX_HEALTH_BUFF + race.BASE_MAX_HEALTH
		elif health <= 0:
			health = 0
			if !godmode_enabled:
				handle_death()
	elif type == 1: # sp
		if is_flat:
			if is_from_skill:
				stamina += amount + (amount * stamina_skill_cost) # test if quik math correct?
			else:
				stamina += amount
			if stamina < 0:
				stamina = 0
				# apply no stamina movement speed debuff
		else:
			if is_from_skill:
				stamina += stamina * amount + (amount * stamina_skill_cost) # test if quik math correct?
			else:
				stamina += stamina * amount
		if stamina > MAX_STAMINA_BUFF + race.BASE_MAX_STAMINA:
			stamina = MAX_STAMINA_BUFF + race.BASE_MAX_STAMINA
	elif type == 2: # mp
		if is_flat:
			if is_from_skill:
				magicka += amount + (amount * magicka_skill_cost) # test if quik math correct?
			else:
				magicka += amount
			if magicka < 0:
				magicka = 0
				# apply no magicka debuff?? wtf would it even do?
		else:
			if is_from_skill:
				magicka += magicka * amount + (amount * magicka_skill_cost) # test if quik math correct?
			else:
				magicka += magicka * amount
		if magicka > MAX_MAGICKA_BUFF + race.BASE_MAX_MAGICKA:
			magicka = MAX_MAGICKA_BUFF + race.BASE_MAX_MAGICKA
	update_stat_bars()

func handle_regeneration():
	if is_unique:
		if health > 0: # temporary way to stop regen when dead
			if health < MAX_HEALTH_BUFF + race.BASE_MAX_HEALTH:
				health += race.BASE_HEALTH_REGEN + (race.BASE_HEALTH_REGEN * HEALTH_REGEN_BUFF)
			if stamina < MAX_STAMINA_BUFF + race.BASE_MAX_STAMINA:
				stamina += race.BASE_STAMINA_REGEN + (race.BASE_STAMINA_REGEN * STAMINA_REGEN_BUFF)
			if magicka < MAX_MAGICKA_BUFF + race.BASE_MAX_MAGICKA:
				magicka += race.BASE_MAGICKA_REGEN + (race.BASE_MAGICKA_REGEN * MAGICKA_REGEN_BUFF)
		update_stat_bars()

func set_stat_bar_max_values(): # player only
	if stat_bars_node:
		stat_bars_node.init(MAX_HEALTH_BUFF + race.BASE_MAX_HEALTH, MAX_STAMINA_BUFF + race.BASE_MAX_STAMINA\
		, MAX_MAGICKA_BUFF + race.BASE_MAX_MAGICKA)
		update_stat_bars()
	else:
		print("no stat_bars_node on " + character_name)

func update_stat_bars(): # for player only
	if stat_bars_node:
		var hp_procentage = (health / (MAX_HEALTH_BUFF + race.BASE_MAX_HEALTH)) * 100
		var sp_procentage = (stamina / (MAX_STAMINA_BUFF + race.BASE_MAX_STAMINA)) * 100
		var mp_procentage = (magicka / (MAX_MAGICKA_BUFF + race.BASE_MAX_MAGICKA)) * 100
		stat_bars_node.set_current_value(health, stamina, magicka)
		stat_bars_node.update_bar_values(hp_procentage, sp_procentage, mp_procentage)

func handle_death():
	print("DEADDD (stats component)")
	if loot_component: # remove check and instead use inv data when interacting with body
		if is_unique: # if body stays after death or not (for important npc)
			get_parent().toggle_death(true)
		else: # for world objects without inventory_data
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
	handle_stat_change(-total_damage, true, ConsumableEffect.StatType.HP, false)

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
	print("Total damage: " + str(final_damage) + " (stats_component)")
	return final_damage

func add_xp(skill : String, amount : int):
	var skill_exists : bool
	for i in skills:
		if skill == i.name:
			skill_exists = true
			break
	if !skill_exists:
		var new_skill = Skill.new()
		new_skill.name = skill
		skills.append(new_skill)
		get_parent().GUI.pop_up.queue_popup("Learned a new skill: " + skill)
	var new_message = "Earned " + str(amount) + " xp in " + skill
	get_parent().GUI.pop_up.add_message(new_message, 3)
	# 0 = misc, 1 = battle, 2 = dialogue, 3 = system, 4 = all
	for i in skills:
		if skill == i.name:
			var counter : int = 1
			var level_up : bool = false
			i.xp += amount
			while i.xp > 0:
				counter += 1
				if counter >= 20:
					print("while loop limit reached (stats_component) -----------------DANGER----------------")
					break
				var xp_check = i.BASE_XP_AMOUNT + i.BASE_XP_INCREASE * i.previous_xp
				if i.xp >= roundi(xp_check):
					i.xp -= roundi(xp_check)
					i.previous_xp += roundi(xp_check)
					i.level += 1
					level_up = true
				else:
					break
				print("current xp: " + str(i.xp) + ", xp needed to lvl:  " + str(roundi(xp_check)))
			if level_up:
				get_parent().GUI.pop_up.queue_popup(skill + " levelled up to " + str(i.level))
			break
