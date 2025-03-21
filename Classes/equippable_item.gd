extends Resource

class_name EquippableItem

enum WeaponType {AXE, BOW, DAGGER, HAMMER, SPECIAL, STAFF, SWORD}
enum ProjectileType {PROJECTILE, BEAM}

@export var is_ranged : bool
@export var weapon_type : WeaponType
@export var projectile : RangedProjectile
@export var projectile_type : ProjectileType
@export var projectile_count : int = 1
@export var damage : Array[Element]
@export var knockback : float
