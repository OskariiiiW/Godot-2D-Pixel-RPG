class_name SlotData
extends Resource

@export var item_data : ItemData
@export_range(0, MAX_STACK_SIZE) var quantity : int = 1: set = set_quantity

const MAX_STACK_SIZE = 99

func set_quantity(value):
	quantity = value
	if quantity > 1 and not item_data.is_stackable:
		quantity = 1
		push_error("%s is not stackable, setting item_count to 1" % item_data.item_name)
