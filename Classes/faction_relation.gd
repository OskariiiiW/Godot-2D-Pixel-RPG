extends Resource

class_name FactionRelation

@export var faction_name : String
@export var faction_relation : int : set = set_amount
@export var faction_characters = {}

func add_character(name : String):
	if not faction_characters.has(name):
		faction_characters[name] = 0

func change_relation(name : String, amount : int, is_set_value : bool):
	add_character(name) # adds the character if it doesnt already exist
	if is_set_value:
		faction_characters[name] = amount
	else:
		faction_characters[name] += amount
	if faction_characters[name] > 100:
		faction_characters[name] = 100
	elif faction_characters[name] < -100:
		faction_characters[name] = -100
	print("new relation: " + str(name) + ": " + str(faction_characters[name]))

func get_relation(name : String):
	add_character(name)
	return faction_characters[name]

func set_amount(value): # used anywhere?
	faction_relation = value # setter, not additive - problem?
	if faction_relation < -100:
		faction_relation = -100
	elif faction_relation > 100:
		faction_relation = 100
	
