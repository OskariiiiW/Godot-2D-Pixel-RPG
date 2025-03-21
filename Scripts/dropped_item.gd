extends StaticBody2D

@onready var item = $Item
@onready var item_component = $ItemComponent

@export var npc_interact : NPCInteractComponent

func _ready():
	if item_component:
		item.texture = item_component.item.item_data.icon
	else:
		print("Item component missing from dropped_item")

func collect():
	print("my only job is to help identify node type for npc interaction")
	queue_free()
