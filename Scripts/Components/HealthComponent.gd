extends Node2D

class_name HealthComponent

@export var loot_base_node : PackedScene
@export var loot : ItemData
@export var loot_quantity : int
@export var stats_component : StatsComponent
@export var MAX_HEALTH := 1
var health : float

func _ready():
	health = MAX_HEALTH

func damage(attack : ItemElementType):
	if stats_component:
		var total_damage = stats_component.calculate_damage(attack)
		health -= total_damage
	else:
		print("no stats component set")
	
	if health <= 0:
		if loot_base_node and loot:
			var inst = loot_base_node.instantiate()
			inst.get_child(2).item.item_data = loot
			inst.get_child(2).item.quantity = loot_quantity
			await get_tree().process_frame # stops deterred() warnings
			owner.get_parent().add_child(inst)
			inst.transform = owner.global_transform
		owner.queue_free()
