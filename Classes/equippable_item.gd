extends Resource

class_name EquippableItem

enum WEAPON_TYPE {AXE, BOW, DAGGER, HAMMER, SPECIAL, STAFF, SWORD}

@export var is_ranged : bool
@export var weapon_type : WEAPON_TYPE
@export var projectile : RangedProjectile
#@export var swing_speed : float #wtf would this do???
@export var damage : ItemElementType
@export var knockback : float
