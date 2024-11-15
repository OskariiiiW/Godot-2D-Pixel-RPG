extends PanelContainer

class_name InventorySlot

@export var type: ItemData.Type
@onready var tool_tip = preload("res://Inventory/Nodes/tool_tip.tscn")

var tool_tip_instance

#TODO - hide tooltip while dragging item

func init(t: ItemData.Type, cms: Vector2):
	type = t
	custom_minimum_size = cms

func _can_drop_data(_at_position, data): #checks slot before doing something with the dragged item
	if data is InventoryItem:
		if type == ItemData.Type.MISC or type == ItemData.Type.BOOK or type == ItemData.Type.CONSUMABLE \
			or type == ItemData.Type.FOOD or type == ItemData.Type.MATERIAL: #checks if non-gear slot
			if get_child_count() == 0: #if slot has no item
				return true #true means dragged item can go into selected slot
			else:
				if type == data.get_parent().type:
					return true
			if get_child(0).data:
				return get_child(0).data.type == data.data.type
		else: #if gear slot
			return data.data.type == type
	return false

func _drop_data(_at_position, data): #where combine and swap happens
	if get_child_count() > 0: #if target slot is not empty
		var item := get_child(0)
		if item.data.name == data.data.name and item.data.is_stackable \
		and item.stack_size != item.MAX_STACK_SIZE:
			if !item == data:
				if item.stack_size + data.stack_size <= item.MAX_STACK_SIZE:
					item.stack_size += data.stack_size
					item.update_stack()
					data.queue_free()
				else:
					data.stack_size = data.stack_size + item.stack_size - data.MAX_STACK_SIZE
					item.stack_size = item.MAX_STACK_SIZE
					item.update_stack()
					data.update_stack()
				return
		item.reparent(data.get_parent())
	if data.get_parent().type > 4 and data.get_parent().type < 13: # if dragged slot is gear slot
		var parent = data.get_parent().get_parent().get_parent()
		if parent.has_method("handle_stat_change"):
			parent.handle_stat_change()
	elif data.get_parent().type == 13: # if dragged slot is weapon slot
		if type == 0: # type = target slot
			var is_unequip : bool = false
			if data.get_parent().get_child_count() < 2:
				is_unequip = true
			else:
				is_unequip = false
			var parent = data.get_parent().get_parent()
			if parent.has_method("handle_weapon_change"):
				parent.handle_weapon_change(is_unequip)
	data.reparent(self)
	if type != 0 and type != 13: # might cause crash with non-player inventories
		get_parent().get_parent().handle_stat_change()
	elif type == 13:
		data.get_parent().get_parent().handle_weapon_change(false)

func _on_mouse_entered():
	if get_child_count() > 0:
		if get_child(0).data and not tool_tip_instance:
			tool_tip_instance = tool_tip.instantiate()
			tool_tip_instance.init(get_child(0).data, get_child(0).stack_size, get_child(0).is_in_gear_slot)
			get_child(0).add_child(tool_tip_instance)
			await get_tree().create_timer(0.35).timeout
			if(!tool_tip_instance == null): #node might already be deleted after timeout
				tool_tip_instance.show()

func _on_mouse_exited():
	if get_child_count() > 0:
		if get_child(0).data and tool_tip_instance:
			if !tool_tip_instance == null:
				tool_tip_instance.free()
