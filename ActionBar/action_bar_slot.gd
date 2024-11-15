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

func _can_drop_data(_at_position, _data): #checks slot before doing something with the dragged item
	return true
	# might cause probleeeems bc no check - any junk can be dragged in - check happens in drop_data

func _drop_data(_at_position, data): #where combine and swap happens
	if data is InventoryItem:
		if data.data.type != ItemData.Type.MISC and data.data.type != ItemData.Type.MATERIAL:
			type = data.data.type
			var new_slot_action = ActionBarSlotAction.new()
			new_slot_action.init(data.data,data.stack_size) #TODO - change to amount of all items
			new_slot_action.data = data.data
			if data.data.type == ItemData.Type.CONSUMABLE or data.data.type == ItemData.Type.FOOD: #checks if label needed
				print("scan player inv and set combined amount to label (actionBarSlot)")
			if get_child_count() > 0: #if target slot is not empty
				var item := get_child(0)
				item.reparent(data.get_parent())
			self.add_child(new_slot_action)
	#elif data is ActionSkill: #TODO - create ActionSkill class
	#	pass
	elif data is ActionBarSlotAction: # when dragging another actionbar slot data to another
		if get_child_count() > 0: #if target slot is not empty
			var item := get_child(0)
			item.reparent(data.get_parent())
		data.reparent(self)

func _on_mouse_entered():
	if get_child_count() > 0:
		if get_child(0).data and not tool_tip_instance:
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
