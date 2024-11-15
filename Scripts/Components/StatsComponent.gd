extends Node2D

class_name StatsComponent

@export var character_name : String
@export var faction_name : String
@export var is_unique : bool # if can be added to relation dictionary - no, they should be there
@export var godmode_enabled : bool # for debug & testing (maybe for essencial npc)
@export var MAX_HEALTH : float = 1.0
@export var HEALTH_REGEN : float = 0.1
@export var MAX_STAMINA : float = 1.0
@export var STAMINA_REGEN : float = 0.1
@export var MAX_MAGICKA : float = 1.0
@export var MAGICKA_REGEN : float = 0.1
@export var resistances : ItemElementType
@export var has_advanced_stats : bool # if char can get bonus from gear - atm only player
@export var stats : Stats
@export var skills : Array[Skill]
@export var loot_component : LootComponent

var stat_bars_node
var health : float #: set = check_if_alive
var stamina : float
var magicka : float

#TODO - fame, karma and intimidation
#TODO - make popups player only
#TODO - if not unique, free after death
#TODO - movement debuff if stam reaches 0??
#TODO - "damage" hp bar
#TODO - bars grow longer if there is a buff that increases max values

func _ready():
	health = MAX_HEALTH # TODO - load value from file
	stamina = MAX_STAMINA # -ll-
	magicka = MAX_MAGICKA # -ll-
	if !resistances:
		print("no resistances set (stats_component) on " + character_name)

func handle_stat_change(amount : float, type : int):
	if type == 0: # hp
		health += amount
		if health <= 0 and !godmode_enabled:
			health = 0
			handle_death()
	elif type == 1: # sp
		stamina += amount
		if stamina < 0:
			stamina = 0
			# apply no stamina debuff
	elif type == 2: # mp
		magicka += amount
		if magicka < 0:
			magicka = 0
			# apply no magicka debuff??
	update_stat_bars()

func handle_regeneration(): # player and player companion only???
	if is_unique: # maybe increase performance by disabling regen on some npc?? NPC dont even have regen yet!!
		if health > 0: # temporary way to stop regen when dead
			if health < MAX_HEALTH:
				health += HEALTH_REGEN
			if stamina < MAX_STAMINA:
				stamina += STAMINA_REGEN
			if magicka < MAX_MAGICKA:
				magicka += MAGICKA_REGEN
		update_stat_bars()

func update_stat_bars(): # for player only
	if stat_bars_node:
		var hp_procentage = (health / MAX_HEALTH) * 100
		var sp_procentage = (stamina / MAX_STAMINA) * 100
		var mp_procentage = (magicka / MAX_MAGICKA) * 100
		stat_bars_node.update_bar_values(hp_procentage, sp_procentage, mp_procentage)

func handle_death():
	if loot_component:
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

func damage(attack : ItemElementType):
	var total_damage
	if resistances:
		if has_advanced_stats: # resistances gets overwritten by equipped gear
			resistances = owner.player_stats_node.resistances
	else:
		resistances = ItemElementType.new()
	total_damage = calculate_damage(attack)
	handle_stat_change(-total_damage, ConsumableEffect.StatType.HP)

func calculate_damage(inc_damage : ItemElementType):
	var total_damage : Array[float]
	var final_damage : float = 0
	total_damage.append(inc_damage.physical - resistances.physical)
	total_damage.append(inc_damage.magical - resistances.magical)
	total_damage.append(inc_damage.poison - resistances.poison)
	total_damage.append(inc_damage.curse - resistances.curse)

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
		PopUpScene.queue_popup("Learned a new skill: " + skill)
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
				PopUpScene.queue_popup(skill + " levelled up to " + str(i.level))
			break
