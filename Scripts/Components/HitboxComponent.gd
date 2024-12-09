extends Area2D

class_name HitboxComponent

@export var stats_component : StatsComponent
@export var simple_stats_component : SimpleStatsComponent

func damage(attack : ItemElementType): #attack : AttackComponent
	if stats_component:
		stats_component.damage(attack)
	elif simple_stats_component:
		simple_stats_component.damage(attack)
	else:
		print("object has no stats_component (hitboxcomponent)")
