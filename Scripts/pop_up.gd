extends Control

var message_box_slot = preload("res://Nodes/UI/message_box_slot.tscn")

@onready var popin_text: Label = $Panel/Margin/PopInText
@onready var movable_message_box: MarginContainer = $VBox/MovableMessageBox
@onready var text_container: VBoxContainer = $VBox/MovableMessageBox/PanelC/Margin2/ScrollC/TextContainer
@onready var scroll_c: ScrollContainer = $VBox/MovableMessageBox/PanelC/Margin2/ScrollC
@onready var show_hide_button: Button = $VBox/MovableMessageBox/PanelC/ShowHideButton

var messages : Array[MessageBoxMessage]
var popin_content_queue : Array[String]
var popping : bool

#TODO - make resizable by player
#TODO - make position reset button in settings

func _ready() -> void:
	movable_message_box.custom_minimum_size.y = 170
	if messages.size() > 0:
		for i in messages:
			var new_message = message_box_slot.instantiate()
			new_message.init(i)
			text_container.add_child(new_message)

func _physics_process(_delta):
	if popin_content_queue.size() > 0 and !popping:
		popping = true
		#print("popin queue: " + str(popin_content_queue.size()))
		popin_text.text = popin_content_queue[0]
		$AnimationPlayer.play("popIn")
		await get_tree().create_timer(1).timeout
		$AnimationPlayer.play_backwards("popIn")
		await get_tree().create_timer(0.5).timeout # bad way to wait until animation finished?
		popin_content_queue.remove_at(0)
		popping = false

func queue_popup(message : String) -> void:
	popin_content_queue.append(message)

func add_message(message: String, type : int): # type might need to be enum instead
	var new_message = message_box_slot.instantiate()
	var new_message_box_message = MessageBoxMessage.new()
	new_message_box_message.message = message
	new_message_box_message.type = type
	messages.append(new_message_box_message)
	new_message.init(new_message_box_message)
	text_container.add_child(new_message)

func filter_messages(type : int): # 0 = misc, 1 = battle, 2 = dialogue, 3 = system, 4 = all
	for i in text_container.get_children():
		i.queue_free()
	var new_array : Array[MessageBoxMessage]
	if type == 4:
		new_array = messages
	else:
		for i in messages:
			if i.type == type:
				new_array.append(i)
	for i in new_array:
		var new_message = message_box_slot.instantiate()
		new_message.init(i)
		text_container.add_child(new_message)

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

func _on_misc_pressed() -> void:
	filter_messages(0)

func _on_battle_pressed() -> void:
	filter_messages(1)

func _on_dialogue_pressed() -> void:
	filter_messages(2)

func _on_system_pressed() -> void:
	filter_messages(3)

func _on_all_pressed() -> void:
	filter_messages(4)
