extends Control

var message_box_slot = preload("res://Nodes/UI/Player/message_box_slot.tscn")

enum MessageType {ALL, DIALOGUE, BATTLE, SYSTEM, MISC}

@onready var popin: MarginContainer = $PopInContainer
@onready var popin_text: Label = $PopInContainer/Panel/Margin/PopInText
@onready var movable_message_box: MarginContainer = $MessageBox/Margin
@onready var text_container: VBoxContainer = $MessageBox/Margin/PanelC/Margin2/ScrollC/TextContainer
@onready var scroll_c: ScrollContainer = $MessageBox/Margin/PanelC/Margin2/ScrollC
@onready var show_hide_button: Button = $MessageBox/Margin/PanelC/ShowHideButton

var max_message_count : int = 20#300 # the max visible messages, after reaching it, for each message, delete 1st
var messages : Array[MessageBoxMessage]
var current_filter : MessageType
var popin_content_queue : Array[String]
var popping : bool

#TODO - make text box resizable by player
#TODO - make text box position reset button in settings

func _ready() -> void:
	movable_message_box.custom_minimum_size.y = 170
	popin.visible = false
	filter_messages(current_filter)

func _physics_process(_delta):
	if popin_content_queue.size() > 0 and !popping:
		popin.visible = true
		popping = true
		popin_text.text = popin_content_queue[0]
		$AnimationPlayer.play("PopIn")
		await get_tree().create_timer(1.1).timeout
		#print("popin que:" + str(popin_content_queue.size()) + " " + popin_text.text)
		popin_content_queue.remove_at(0)
		popping = false

func queue_popup(message : String) -> void:
	popin_content_queue.append(message)

func add_message(message: String, type : int): # type might need to be enum instead
	var new_message = null
	if current_filter == 0 or current_filter == type:
		new_message = message_box_slot.instantiate()
	var new_message_box_message = MessageBoxMessage.new()
	new_message_box_message.message = message
	new_message_box_message.type = type
	if messages.size() == max_message_count:
		messages.pop_front()
	messages.append(new_message_box_message)
	if new_message:
		new_message.init(new_message_box_message)
		text_container.add_child(new_message)
	# needs a check to see whether scrollbar was already at max
	await get_tree().create_timer(0.1).timeout
	scroll_c.scroll_vertical = 30 * messages.size() # 1 line message size 54px
	# needs a frame skip instead of timer to execute smoothly
	#print(scroll_c.scroll_vertical)

func filter_messages(type : MessageType):
	for i in text_container.get_children():
		i.queue_free()
	var new_array : Array[MessageBoxMessage]
	if type == MessageType.ALL:
		new_array = messages
	else:
		for i in messages:
			if i.type == type:
				new_array.append(i)
	for i in new_array.size():
		if i <= max_message_count: # shows first 3 - should be last 3 :P
			var new_message = message_box_slot.instantiate()
			new_message.init(new_array[i])
			text_container.add_child(new_message)
		else:
			break

func _on_show_hide_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		movable_message_box.custom_minimum_size.y = 50
		show_hide_button.text = "Show"
		scroll_c.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	else:
		movable_message_box.custom_minimum_size.y = 170
		show_hide_button.text = "Hide"
		scroll_c.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	movable_message_box.set_anchors_preset(Control.PRESET_BOTTOM_LEFT) # to reset the position after changing size

func _on_tab_bar_tab_changed(tab: int) -> void:
	filter_messages(tab)
