extends Node2D

class_name ItemComponent

@export var item : SlotData

func _on_body_entered(body):
	if body.has_method("collect_item"):
		var remaining_stack = body.collect_item(item)
		if remaining_stack == 0:
			get_parent().queue_free()
		else:
			item.quantity = remaining_stack
			get_tree().root.get_child(2).gui.pop_up.add_message("Inventory full", 3) # might cause spam
			# 0 = misc, 1 = battle, 2 = dialogue, 3 = system, 4 = all
