class_name ItemData
extends Resource

enum Type {MISC, BOOK, CONSUMABLE, FOOD, MATERIAL, HEAD, NECK, BACK, CHEST, HANDS, RING, LEGS, FEET, WEAPON}

@export_range(0, 7) var tier : int #= 1: set = set_tier
@export var type: Type
@export var name : String
@export var value : int
@export var weight : float
@export_multiline var description: String
@export var is_stackable : bool
@export var weapon : EquippableItem
@export var gear : EquippableGear
@export var consumable : Consumable
@export var texture : Texture2D
@export var modifiers : Array[ConsumableEffect] # buffs/debuffs item has
# 0 = common, 1 = uncommon, 2 = rare, 3 = epic, 4 = legendary, 5 = mythic, 6 = godly, (7 = demonic)
