extends StaticBody2D

@onready var chest = $Chest

@export var closed_texture : Texture2D
@export var opened_texture : Texture2D
@export var inventory_data : InventoryData
@export var npc_interact_component : NPCInteractComponent

var chest_opened = false
var GUI

func _ready():
	chest.texture = closed_texture
	await get_tree().create_timer(0.2).timeout # pretty bad way to ensure everything loads
	GUI = get_tree().root.get_child(2).gui

#TODO - (maybe?) generate loot based on rarity if not manually set inventory_data
#TODO - edit chest textures so the bottom of the chest stays in the same place
#TODO (maybe?) - make it possible to have more than 1 extInv open

func interact():
	if inventory_data:
		if not chest_opened and not GUI.external_inventory.visible:
			GUI.init_external_inventory(inventory_data.slot_datas.size(), inventory_data)
			chest.texture = opened_texture
			chest_opened = true
		else:
			save_inventory_data()
			GUI.hide_external_inventory()
			chest.texture = closed_texture
			chest_opened = false
	else:
		print("No inventory_data set")

func npc_interact(item : SlotData, is_taking : bool): #TODO - currently not used
	var item_counter = item.quantity
	if is_taking:
		for i in inventory_data.slot_datas:
			if i.item_data == item.item_data:
				print("item counter " + str(item_counter))
				if item_counter - i.quantity < 0:
					i.quantity =- item_counter
				else:
					item_counter =- i.quantity
				if item_counter == 0:
					save_inventory_data()
					return true
	else: # should the npc actually have the items in their inv???
		for i in inventory_data.slot_datas.size():
			if GUI.external_inventory.inv.get_child(i).get_child_count() >! 0: #if slot has data
				inventory_data.slot_datas[i] = item # puts slot data in an empty slot
				save_inventory_data()
				return true
	if is_taking:
		print("container doesnt either have the item or stack not big enough")
	else:
		print("container full")
	return false

func save_inventory_data():
	var new_inventory = InventoryData.new()
	for i in inventory_data.slot_datas.size(): # problems if inv size changes??
		var new_slot_data
		if GUI.external_inventory.inv.get_child(i).get_child_count() > 0: #if slot has data
			new_slot_data = SlotData.new()
			new_slot_data.item_data = GUI.external_inventory.inv.get_child(i).get_child(0).data
			new_slot_data.quantity = GUI.external_inventory.inv.get_child(i).get_child(0).stack_size
		new_inventory.slot_datas.append(new_slot_data)
	GUI.player_inventory.save_inventory_data()
	inventory_data = new_inventory

func _on_inventory_boundary_body_exited(_body):
	if chest_opened:
		save_inventory_data()
		GUI.hide_external_inventory()
		chest.texture = closed_texture
		chest_opened = false
