extends Area2D

class_name HitboxComponent

@export var stats_component : StatsComponent
@export var simple_stats_component : SimpleStatsComponent
@export var buff_component : BuffComponent

func damage(inc_dmg : Array[Element]):
	if stats_component:
		stats_component.damage(inc_dmg)
	elif simple_stats_component:
		simple_stats_component.damage(inc_dmg)
	else:
		print("object has no stats_component (hitboxcomponent)")

func add_buff(buff : ConsumableEffect):
	if stats_component:
		if buff_component: # npc
			buff_component.add_buff(buff)
		else: # player
			get_parent().buff_list.add_buff(buff)
