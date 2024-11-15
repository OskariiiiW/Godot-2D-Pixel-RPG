class_name ShopSlot
extends PanelContainer

@export var type: ItemData.Type
@onready var tool_tip = preload("res://Inventory/Nodes/tool_tip.tscn")
@onready var shop_confirm = preload("res://Inventory/shop_action_confirm.tscn")

var inv_item_child
var tool_tip_instance
var shop_mode : String

#TODO - remove being able to drag items

func _ready() -> void:
	inv_item_child = get_child(0)

func init(t: ItemData.Type, cms: Vector2, _shop_mode : String):
	type = t
	custom_minimum_size = cms
	shop_mode = _shop_mode

func check_remaining_stack(stack_size : int):
	if inv_item_child.stack_size - stack_size == 0:
		var shop_ui = get_tree().root.get_child(3).gui.shop_ui
		shop_ui.check_if_empty()
		#TODO - add item to npc shop inv
		get_parent().queue_free()
	else:
		inv_item_child.stack_size -= stack_size
		get_parent().get_child(1).text = str(inv_item_child.stack_size * inv_item_child.data.value)
		inv_item_child.update_stack()

func _on_mouse_entered():
	if get_child_count() > 0:
		if inv_item_child.data and not tool_tip_instance:
			tool_tip_instance = tool_tip.instantiate()
			tool_tip_instance.init(inv_item_child.data, inv_item_child.stack_size, inv_item_child.is_in_gear_slot)
			inv_item_child.add_child(tool_tip_instance)
			await get_tree().create_timer(0.35).timeout
			if(!tool_tip_instance == null): #node might already be deleted after timeout
				tool_tip_instance.show()

func _on_mouse_exited():
	if get_child_count() > 0:
		if inv_item_child.data and tool_tip_instance:
			if !tool_tip_instance == null:
				tool_tip_instance.free()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var confirm = shop_confirm.instantiate()
		confirm.init(shop_mode, inv_item_child.data, inv_item_child.stack_size)
		inv_item_child.add_child(confirm)
