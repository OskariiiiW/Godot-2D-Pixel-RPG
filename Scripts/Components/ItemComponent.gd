extends Node2D

class_name ItemComponent

@export var item : SlotData

func _on_body_entered(body):
	print("dropped item stack: " + str(item.quantity))
	if body.has_method("collect_item"):
		var remaining_stack = body.collect_item(item)
		if remaining_stack == 0:
			get_parent().queue_free()
		else:
			item.quantity = remaining_stack
			print("dropped_item - No room in inv")
