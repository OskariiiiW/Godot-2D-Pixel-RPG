extends Control

@onready var slot_container: HBoxContainer = $Margin/PanelC/Margin2/SlotContainer

var slots : Array[ActionBarSlot]

func _ready() -> void:
	for i in slot_container.get_children():
		slots.append(i)

func _can_drop_data(_at_position, _data):
	return true

func _drop_data(_at_position, data):
	if data is ActionBarSlotAction:
		data.queue_free()

func activate_slot(i : int, player : Player):
	slots[i].activate(player)
