extends Node2D

class_name RelationshipComponent

@export var faction_relations : Array[FactionRelation]

var factions : Array[String] = ["PlayerFaction", "DummyThiccFaction", "npc_faction"]
#TODO - come up with suitable factions
#TODO - save these somewhere

func _ready() -> void:
	#TODO - check if existing faction_relations file exists
	for i in factions:
		var faction = FactionRelation.new()
		faction.faction_name = i
		faction.faction_relation = 0
		faction_relations.append(faction)

func change_char_relation(character_name : String, faction : String, amount : int, is_set_value : bool):
	for i in faction_relations:
		if i.faction_name == faction:
			i.change_relation(character_name, amount, is_set_value)

func change_fact_relation(faction : String, amount : int, is_set_value : bool):
	for i in faction_relations:
		if i.faction_name == faction:
			if is_set_value:
				i.faction_relation = amount
			else:
				i.faction_relation += amount

func check_char_relation(character_name : String, faction : String):
	for i in faction_relations:
		if i.faction_name == faction:
			return i.get_relation(character_name)

func check_fact_relation(faction: String):
	for i in faction_relations:
		if i.faction_name == faction:
			return i.faction_relation

#func faction_exists(faction : String): # was for new faction adding
#	for i in faction_relations:
#		if i.faction_name == faction:
#			return true
#	return false
