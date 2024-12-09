extends Resource

class_name Race

enum RaceType {UNKNOWN, HUMAN, ELF, HALFELF, BEASTFOLK, DWARF, GOBLIN, DEMON, VAMPIRE, INSECT, BEAST, ELEMENTAL}

@export var race_type : RaceType : set = change_race
var race_name : String

@export var BASE_MAX_HEALTH : float = 1.0
@export var BASE_HEALTH_REGEN : float = 0.1

@export var BASE_MAX_STAMINA : float = 1.0
@export var BASE_STAMINA_REGEN : float = 0.1

@export var BASE_MAX_MAGICKA : float = 1.0
@export var BASE_MAGICKA_REGEN : float = 0.1

@export var resistances : ItemElementType# : set = wtf

#func wtf(value):
#	print(value)

func change_race(value):
	if value == RaceType.UNKNOWN:
		pass
	elif value == RaceType.HUMAN:
		race_name = "Human"
		BASE_MAX_HEALTH = 30.0
		BASE_HEALTH_REGEN = 0.1
		BASE_MAX_STAMINA = 60.0
		BASE_STAMINA_REGEN = 0.3
		BASE_MAX_MAGICKA = 30.0
		BASE_MAGICKA_REGEN = 0.1
		resistances = ItemElementType.new()
	elif value == RaceType.ELF:
		pass
	elif value == RaceType.HALFELF:
		pass
	elif value == RaceType.BEASTFOLK:
		pass
	elif value == RaceType.DWARF:
		pass
	elif value == RaceType.GOBLIN:
		pass
	elif value == RaceType.DEMON:
		pass
	elif value == RaceType.VAMPIRE:
		pass
	elif value == RaceType.INSECT:
		pass
	elif value == RaceType.BEAST:
		pass
	elif value == RaceType.ELEMENTAL:
		pass
