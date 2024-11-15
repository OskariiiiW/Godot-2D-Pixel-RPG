extends PanelContainer

var inventory_item_slot = preload("res://Inventory/Nodes/inventory_slot.tscn")

@onready var inv: GridContainer = $MarginContainer/Inv

var slot_amount
var external_inventory : InventoryData

var isDragging = false
var movedToTop = false # dunno if even works
var parent
var offset

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			offset = get_local_mouse_position()
			isDragging = true

func _ready():
	var _parent = get_parent() # UI drag
	if _parent is Control: # UI drag
		parent = _parent # UI drag

#TODO (maybe?) - add arg to function for some slots to be of specific type
#TODO - save item array after modifying it (items disappear if you put them in the chest)
#TODO (maybe?) - reset GUI position every time you launch the game or make it possible to do manually
#TODO - prevent inventory from being dragged outside screen

func init(slots : int, item_datas : InventoryData):
	slot_amount = slots
	external_inventory = item_datas
	update_inventory()

func update_inventory():
	for i in inv.get_children():
		i.free()

	for i in slot_amount: # creates empty slots for each slot in inventory
		var slot := inventory_item_slot.instantiate()
		slot.init(ItemData.Type.MISC, Vector2(64,64))
		inv.add_child(slot)
		
		if external_inventory.slot_datas[i]: # fills specific slots with item data
			var item = InventoryItem.new()
			item.init(external_inventory.slot_datas[i].item_data, external_inventory.slot_datas[i].quantity)
			item.is_in_gear_slot = false
			inv.get_child(i).add_child(item)

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
