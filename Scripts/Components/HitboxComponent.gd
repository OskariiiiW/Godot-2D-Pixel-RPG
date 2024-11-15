extends Area2D

class_name HitboxComponent

@export var stats_component : StatsComponent

func damage(attack : ItemElementType): #attack : AttackComponent
	if stats_component:
		stats_component.damage(attack)
	else:
		print("object has no stats_component (hitboxcomponent)")
