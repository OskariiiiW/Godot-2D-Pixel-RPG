extends Control

@onready var name_label: Label = $PContainer/Margin/VBox/ItemName
@onready var amount_slider: HSlider = $PContainer/Margin/VBox/AmountSlider
@onready var label: Label = $PContainer/Margin/VBox/CostText

var GUI
var shop_mode : String
var item_data : ItemData
var stack_size : int
var total_price : int
var slider_value : float = 1.0

#TODO - if not enough money, buy as much from desired stack as possible

func _ready() -> void:
	GUI = get_tree().root.get_child(2).gui
	name_label.text = item_data.name
	total_price = item_data.value #value for a stack of 1 of the item
	if stack_size == 1:
		amount_slider.visible = false
		if shop_mode == "Buying":
			label.text = "Buy for: " + str(item_data.value) + "?"
		elif shop_mode == "Selling":
			label.text = "Sell for: " + str(item_data.value) + "?"
	else:
		if shop_mode == "Buying":
			label.text = "Buy 1 for: " + str(item_data.value) + "?"
		elif shop_mode == "Selling":
			label.text = "Sell 1 for: " + str(item_data.value) + "?"
		amount_slider.max_value = stack_size

func init(_shop_mode : String, _item_data : ItemData, _stack_size: int): # executes before _ready
	shop_mode = _shop_mode
	item_data = _item_data
	stack_size = _stack_size

func _on_amount_slider_value_changed(value: float) -> void:
	total_price = int(value) * item_data.value
	if shop_mode == "Buying":
		label.text = "Buy " + str(value) + " for: " + str(total_price) + "?"
	elif shop_mode == "Selling":
		label.text = "Sell " + str(value) + " for: " + str(total_price) + "?"
	slider_value = value

func _on_yes_pressed() -> void:
	var new_slot = SlotData.new()
	new_slot.item_data = item_data
	new_slot.quantity = int(slider_value)
	#var shop_ui = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()\
		#.get_parent().get_parent().get_parent() # pls kill me
	if shop_mode == "Buying":
		#var remaining_stack = GUI.player.inventory_data.add_item(new_slot)
		var remaining_stack = GUI.player_inventory.add_item(new_slot)
		if remaining_stack != int(slider_value):
			total_price = (int(slider_value) - remaining_stack) * item_data.value
			var was_successful = GUI.shop_ui.update_gold_values(total_price, true) # checks if has enough gold
			if was_successful:
				get_parent().get_parent().check_remaining_stack(int(slider_value) - remaining_stack)
			else:
				print("dafuq?")
		else:
			GUI.pop_up.queue_popup("No room in inventory")
	else: # Selling
		var was_successful = GUI.shop_ui.update_gold_values(total_price, false)
		if was_successful:
			get_tree().root.get_child(3).player.inventory_data.remove_item(new_slot, stack_size)
			get_parent().get_parent().check_remaining_stack(int(slider_value))
			GUI.shop_ui.add_item(new_slot)
	queue_free()

func _on_cancel_pressed() -> void:
	queue_free()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		queue_free()
