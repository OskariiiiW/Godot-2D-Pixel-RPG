extends PanelContainer

class_name ActionBarSlot

@onready var tool_tip = preload("res://Inventory/Nodes/tool_tip.tscn")

var type: ItemData.Type # only used when dragging items to action bar
var tool_tip_instance

#TODO - hide tooltip while dragging item
#BUG - tooltip can be partly outside screen

func activate(player : Player):
	if get_child_count() > 0:
		get_child(0).activate(player)

func _can_drop_data(_at_position, _data):
	return true

func _drop_data(_at_position, data): #where combine and swap happens
	if data is InventoryItem:
		if data.data.type == ItemData.Type.CONSUMABLE or data.data.type == ItemData.Type.FOOD:
			type = data.data.type
			var player_inv = get_tree().root.get_child(2).gui.player_inventory
			var stack = player_inv.get_item_count(data.data)
			var new_slot_action = ActionBarSlotAction.new()
			new_slot_action.init(data.data,stack)
			if get_child_count() > 0: #if target slot is not empty
				get_child(0).queue_free()
			self.add_child(new_slot_action)
	elif data is ActionSkill:
		if get_child_count() > 0: #if target slot is not empty
			get_child(0).queue_free()
		#self.add_child(xxx) # need a way to convert to a node
	elif data is ActionBarSlotAction or data is ActionSkill: # when dragging another actionbar slot data to another
		if get_child_count() > 0: #if target slot is not empty
			var item := get_child(0)
			item.reparent(data.get_parent())
		data.reparent(self)

func _on_mouse_entered():
	if get_child_count() > 0:
		if get_child(0).data and not tool_tip_instance:
			if get_child(0).data is ItemData:
				tool_tip_instance = tool_tip.instantiate()
				tool_tip_instance.init(get_child(0).data, get_child(0).stack_size, false)
				get_child(0).add_child(tool_tip_instance)
				await get_tree().create_timer(0.35).timeout
				if(!tool_tip_instance == null): #node might already be deleted after timeout
					tool_tip_instance.show()

func _on_mouse_exited():
	if get_child_count() > 0:
		if get_child(0).data and tool_tip_instance:
			if !tool_tip_instance == null:
				tool_tip_instance.free()
