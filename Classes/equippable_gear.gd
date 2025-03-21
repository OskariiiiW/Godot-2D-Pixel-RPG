extends Resource

class_name EquippableGear

#enum EQUIP_SLOT {CHEST, BACK, FEET, HANDS, HEAD, LEGS, NECK, RING}
enum WEIGHT_CLASS {NONE, LIGHT, MEDIUM, HEAVY}

@export var resistances : Array[Element]
@export var weight_class : WEIGHT_CLASS
