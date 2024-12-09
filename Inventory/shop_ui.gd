extends Control

var shop_slot = preload("res://Inventory/Nodes/shop_slot.tscn")

@onready var current_shop_mode: Button = $Panel/HBox/ItemsContainer/Margin/VBox/SwitchButton
@onready var npc_name: Label = $Panel/HBox/NpcInfo/Margin/VBox/NpcName
@onready var npc_img: TextureRect = $Panel/HBox/NpcInfo/Margin/VBox/NpcImg
@onready var npc_relation: Label = $Panel/HBox/NpcInfo/Margin/VBox/NpcRelation
@onready var discount: Label = $Panel/HBox/NpcInfo/Margin/VBox/Discount
@onready var p_gold: Label = $Panel/HBox/ItemsContainer/Margin/VBox/HBox2/PGold
@onready var n_gold: Label = $Panel/HBox/NpcInfo/Margin/HBox/NGold
@onready var nothing_to_sell: Label = $Panel/HBox/ItemsContainer/Margin/NothingToSell
@onready var slot_parent: GridContainer = $Panel/HBox/ItemsContainer/Margin/VBox/Scroll/SlotParent

var player : Player
var npc : NonPlayerCharacter
var shop_mode : String

#TODO - when selling, only show items npc is interested in

func init(_npc : NonPlayerCharacter):
	shop_mode = "Buying"
	current_shop_mode.text = shop_mode
	player = get_tree().root.get_child(2).player
	npc = _npc
	if npc.shop_inventory:
		npc_name.text = npc.stats_component.character_name
		npc_img.texture = npc.character_image
		var player_name = player.stats_component.character_name
		npc_relation.text = "Relation: " + str(npc.relationship_component.faction_relations[0]\
			.get_relation(player_name))
		p_gold.text = str(player.inventory_data.gold)
		n_gold.text = str(npc.gold)
		fill_slots()
		visible = true
	else:
		print("no npc shop inv")
		player.can_move = true
		player.can_attack = true
		npc.is_in_dialogue = false

func fill_slots():
	if shop_mode == "Buying":
		handle_slot_datas(npc.shop_inventory)
	elif shop_mode == "Selling":
		handle_slot_datas(player.inventory_data.player_inventory)

func handle_slot_datas(inv_data : InventoryData): # made to reduce lines of code
	var has_items : bool
	for i in inv_data.slot_datas: # checks if has any items in inv
		if i:
			has_items = true
			break
	if !has_items:
		var shop_text = "{name} has nothing to sell"
		if shop_mode == "Buying":
			nothing_to_sell.text = shop_text.format({"name" : npc.stats_component.character_name})
		else:
			print(shop_text.format({"name" : player.stats_component.character_name}))
			nothing_to_sell.text = shop_text.format({"name" : player.stats_component.character_name})
		nothing_to_sell.visible = true
	else:
		nothing_to_sell.visible = false
		for i in inv_data.slot_datas:
			if i: # for player bc not all slots have data
				# still gonna cause crash if slotdata with no itemdata
				var vbox = VBoxContainer.new()
				var price_label = Label.new()
				var price = i.item_data.value * i.quantity
				price_label.text = str(price)
				price_label.clip_text = true
				price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				if shop_mode == "Buying":
					if price > player.inventory_data.gold: # Turns price red if doesnt have enough gold
						price_label.set("theme_override_colors/font_color","Red")
				var slot = shop_slot.instantiate()
				slot.init(ItemData.Type.MISC, Vector2(64,64), shop_mode)
				var item = InventoryItem.new()
				item.init(i.item_data, i.quantity)
				item.is_in_gear_slot = false
				slot.add_child(item)
				vbox.add_child(slot)
				vbox.add_child(price_label)
				slot_parent.add_child(vbox)

func _on_switch_button_pressed() -> void:
	if shop_mode == "Buying":
		save_inventory_data()
		shop_mode = "Selling"
	elif shop_mode == "Selling":
		shop_mode = "Buying"
	for i in slot_parent.get_children():
		i.free()
	current_shop_mode.text = shop_mode
	fill_slots()

func _on_exit_pressed() -> void:
	save_inventory_data()
	for i in slot_parent.get_children():
		i.free()
	visible = false
	player.can_move = true
	player.can_attack = true
	player.is_in_dialogue = false
	npc.is_in_dialogue = false

func update_gold_values(value : int, is_buying : bool): # maybe change name to smth better
	if is_buying:
		if player.inventory_data.gold - value >= 0:
			player.inventory_data.gold -= value
			npc.gold += value
			update_item_cost_color()
		else:
			player.GUI.pop_up.queue_popup("You don't have enough money")
			return false
	else:
		if npc.gold - value >= 0:
			player.inventory_data.gold += value
			npc.gold -= value
		else:
			player.GUI.pop_up.queue_popup(npc.stats_component.character_name + " doesn't have enough money")
			return false
	p_gold.text = str(player.inventory_data.gold)
	n_gold.text = str(npc.gold)
	return true

func update_item_cost_color():
	for i in slot_parent.get_child_count():
		var gold = int(slot_parent.get_child(i).get_child(1).text)
		if gold > player.inventory_data.gold: # Turns price red if doesnt have enough gold
			slot_parent.get_child(i).get_child(1).set("theme_override_colors/font_color","Red")

func save_inventory_data():
	if shop_mode == "Buying":
		var new_inventory = InventoryData.new()
		for i in slot_parent.get_child_count():
			var new_slot_data = SlotData.new()
			new_slot_data.item_data = slot_parent.get_child(i).get_child(0).get_child(0).data
			new_slot_data.quantity = slot_parent.get_child(i).get_child(0).get_child(0).stack_size
			new_inventory.slot_datas.append(new_slot_data)
		npc.shop_inventory = new_inventory

func check_if_empty(): # checks if inv is empty and so has nothing to sell
	if slot_parent.get_child_count() == 1: # 1 because this happens before slot gets free()
		nothing_to_sell.visible = true

func add_item(item : SlotData):
	var item_array : Array[SlotData]
	var overflow : int
	
	for i in npc.shop_inventory.slot_datas:
		if i.item_data == item.item_data and i.quantity < 99 and i.item_data.is_stackable:
			item_array.append(i)
			print("adding to item_array")

	for i in item_array:
		if overflow > 0:
			i.quantity += overflow
			if !i.quantity <= 99:
				overflow = i.quantity - 99
				i.quantity = 99
		else:
			i.quantity += item.quantity
		if i.quantity > 99:
			overflow = i.quantity - 99
			i.quantity = 99

	if item_array.size() == 0:
		npc.shop_inventory.slot_datas.append(item)

	if overflow > 0:
			var new_slot = SlotData.new()
			new_slot.item_data = item.item_data
			new_slot.quantity = overflow
			npc.shop_inventory.slot_datas.append(new_slot)
