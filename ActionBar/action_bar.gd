extends Control

@onready var slot_container: HBoxContainer = $Margin/PanelC/Margin2/SlotContainer

var slots : Array[ActionBarSlot]

func _ready() -> void:
	for i in slot_container.get_children():
		slots.append(i)
		if i.get_child_count() > 0:
			i.get_child(0).init(i.get_child(0).data, 1)

func _can_drop_data(_at_position, _data):
	return true

func _drop_data(_at_position, data):
	if data is ActionBarSlotAction:
		data.queue_free()

func activate_slot(i : int, player : Player):
	slots[i].activate(player)
