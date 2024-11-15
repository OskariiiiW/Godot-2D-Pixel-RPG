extends PanelContainer

var base_player_inventory = preload("res://Inventory/player_inventory.tres")
var inventory_item_slot = preload("res://Inventory/Nodes/inventory_slot.tscn")

@onready var inv: GridContainer = $MarginContainer/Inv

@export var gold : int

var player_inventory : InventoryData
var isDragging = false
var movedToTop = false # dunno if even works
var parent
var offset

#TODO - drop item if slot has one before deletion (for when inv size changes)
#TODO - when picking/buying stack, if no room for full stack, only get as much as can and leave rest (picking done?)
#TODO - prevent inventory from being dragged outside screen

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			offset = get_local_mouse_position()
			isDragging = true

func _ready():
	player_inventory = base_player_inventory
	
	for i in player_inventory.slot_datas.size(): #makes empty slots for every object in array
		var slot := inventory_item_slot.instantiate()
		slot.init(ItemData.Type.MISC, Vector2(64,64))
		inv.add_child(slot)
		
		if player_inventory.slot_datas[i]: #fills slots with item data if slot has items
			if player_inventory.slot_datas[i].item_data:
				var item = InventoryItem.new()
				item.init(player_inventory.slot_datas[i].item_data, player_inventory.slot_datas[i].quantity)
				item.is_in_gear_slot = false
				inv.get_child(i).add_child(item)
			else: # clears slotdata if item data missing
				player_inventory.slot_datas[i] = null
	
	var _parent = get_parent() # UI drag
	if _parent is Control: # UI drag
		parent = _parent # UI drag

func remove_item(item: SlotData, or_stack_size : int):
	var new_slot = SlotData.new()
	new_slot.item_data = item.item_data
	new_slot.quantity = or_stack_size

	for i in inv.get_child_count():
		if inv.get_child(i).get_child_count() > 0: # if slot_data has data (stops crash)
			if inv.get_child(i).get_child(0).data == item.item_data \
			and inv.get_child(i).get_child(0).stack_size == or_stack_size: #item.quantity
				if item.quantity == or_stack_size:
					inv.get_child(i).get_child(0).free()
				else:
					inv.get_child(i).get_child(0).stack_size = (or_stack_size - item.quantity)
				save_inventory_data()

func add_item(item : SlotData):
	for i in inv.get_child_count(): # combine stack with existing
		if inv.get_child(i).get_child_count() > 0: # if slot_data has data (stops crash)
			if inv.get_child(i).get_child(0).data.name == item.item_data.name \
			and inv.get_child(i).get_child(0).data.is_stackable \
			and inv.get_child(i).get_child(0).stack_size + item.quantity <= 99:
				inv.get_child(i).get_child(0).stack_size += item.quantity
				save_inventory_data()
				return 0
			elif inv.get_child(i).get_child(0).data.name == item.item_data.name \
			and inv.get_child(i).get_child(0).data.is_stackable:
				var remaining_stack = handle_stack_combine(item)
				if remaining_stack > 0: # tries to create new slot with remaining stack
					for z in inv.get_child_count():
						if inv.get_child(z).get_child_count() == 0:
							var new_inventory_item = InventoryItem.new()
							new_inventory_item.data = item.item_data
							new_inventory_item.stack_size = remaining_stack
							inv.get_child(z).add_child(new_inventory_item)
							save_inventory_data()
							return 0
				save_inventory_data()
				return remaining_stack

	for i in inv.get_child_count(): # create new slot with item
		if inv.get_child(i).get_child_count() == 0:
			var new_inventory_item = InventoryItem.new()
			new_inventory_item.data = item.item_data
			new_inventory_item.stack_size = item.quantity
			inv.get_child(i).add_child(new_inventory_item)
			save_inventory_data()
			return 0
	return item.quantity

func handle_stack_combine(item : SlotData): # runs through every itemstack of same type and sees if can combine
	var item_stack : Array[InventoryItem]
	for i in inv.get_child_count(): # combine stack with existing
		if inv.get_child(i).get_child_count() > 0: # if slot_data has data
			if inv.get_child(i).get_child(0).data.name == item.item_data.name \
			and inv.get_child(i).get_child(0).data.is_stackable \
			and inv.get_child(i).get_child(0).stack_size < 99:
				item_stack.append(inv.get_child(i).get_child(0))
	for i in item_stack:
		if i.stack_size + item.quantity > 99:
			item.quantity = item.quantity + i.stack_size - 99
			i.stack_size = 99
		elif i.stack_size + item.quantity <= 99:
			i.stack_size += item.quantity
			item.quantity = 0
			break
	return item.quantity

func save_inventory_data():
	var new_inventory = InventoryData.new()
	for i in player_inventory.slot_datas.size(): # problems if inv size changes??
		var new_slot_data
		if inv.get_child(i).get_child_count() > 0: #if slot has data (stops crash)
			new_slot_data = SlotData.new()
			new_slot_data.item_data = inv.get_child(i).get_child(0).data
			new_slot_data.quantity = inv.get_child(i).get_child(0).stack_size
		new_inventory.slot_datas.append(new_slot_data)
	player_inventory = new_inventory
	update_inventory()

func update_inventory():
	for i in inv.get_children():
		i.free()
	for i in player_inventory.slot_datas.size(): #makes empty slots for every object in array
		var slot := inventory_item_slot.instantiate()
		slot.init(ItemData.Type.MISC, Vector2(64,64))
		inv.add_child(slot)
		
		if player_inventory.slot_datas[i]: #fills slots with item data if slot has items
			var item = InventoryItem.new()
			item.init(player_inventory.slot_datas[i].item_data, player_inventory.slot_datas[i].quantity)
			item.is_in_gear_slot = false
			inv.get_child(i).add_child(item)

func reduce_inventory_size(): # currently not used anywhere
	player_inventory.slot_datas.remove_at(player_inventory.slot_datas.size() - 1)
	var slot = inv.get_child(player_inventory.slot_datas.size())
	slot.queue_free()
	print("pop goes the balloon")

func increase_inventory_size(): # currently not used anywhere
	player_inventory.slot_datas.push_back(null)
	var slot := inventory_item_slot.instantiate()
	slot.init(ItemData.Type.MISC, Vector2(64,64))
	%Inv.add_child(slot)

func _process(_delta): # UI drag
	if isDragging:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var pos = get_viewport().get_mouse_position() - offset;

			if (parent != null):
				pos -= parent.global_position

				var _w = parent.size.x - size.x
				var _h = parent.size.y - size.y

				if (pos.x <= 0):
					pos.x = 0
				elif (pos.x > _w):
					pos.x = _w

				if (pos.y <= 0):
					pos.y = 0
				elif (pos.y > _h):
					pos.y = _h
			if !movedToTop && parent != null: # test
				parent.move_child(self, parent.get_child_count())
				movedToTop = true

			position = pos
		else:
			isDragging = false
			movedToTop = false
