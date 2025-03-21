class_name ItemData
extends Resource

enum Rarity {COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, MYTHIC, GODLY, DEMONIC}
enum Type {MISC, BOOK, CONSUMABLE, FOOD, MATERIAL, HEAD, NECK, BACK, CHEST, HANDS, RING, LEGS, FEET, WEAPON}

@export var tier : Rarity = Rarity.COMMON
@export var type: Type
@export var name : String
@export var value : int
@export var weight : float
@export_multiline var description: String
@export var is_stackable : bool
@export var weapon : EquippableItem
@export var gear : EquippableGear
@export var icon : Texture2D
@export var effects : Array[ConsumableEffect] # buffs/debuffs item has
