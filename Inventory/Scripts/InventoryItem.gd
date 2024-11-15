class_name InventoryItem
extends TextureRect

@export var data: ItemData

const MAX_STACK_SIZE = 99

var is_in_gear_slot = true # wtf dis does? - it is set in playerInv in init
var stack_label : Label
var stack_size

#TODO taking from stack, take single from stack

func _ready():
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if !stack_size: #fixes null stack size in gear slots
		stack_size = 1
	stack_label = Label.new()
	self.add_child(stack_label)
	
	if data:
		texture = data.texture
		stack_label.text = str(stack_size)
		if stack_size == 1:
			stack_label.hide()

func init(d: ItemData, s: int):
	data = d
	stack_size = s

func update_stack():
	stack_label.text = str(stack_size)

	if stack_size > 1:
		stack_label.show()
	else:
		print("stack size: " + str(stack_size) + " (for seeing if neg stack) (inventoryItem)")
		stack_label.hide()

func _get_drag_data(at_position):
	if data: # disables dragging with empty slots - might be redundant now
		set_drag_preview(make_drag_preview(at_position))
		return self

func make_drag_preview(at_position):
	var t := TextureRect.new()
	t.texture = texture
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = size
	t.modulate.a = 0.5
	t.position = Vector2(-at_position)

	var c := Control.new()
	c.add_child(t)
	return c
