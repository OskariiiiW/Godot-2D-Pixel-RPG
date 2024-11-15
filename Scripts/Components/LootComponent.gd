extends Node2D

class_name LootComponent

@export var loot_base_node : PackedScene
@export var loot : ItemData # what drops when destroyed (only for world objects)
@export var loot_quantity : int = 1 # stack size of dropped item
