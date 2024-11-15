extends Control

@onready var npc_image: TextureRect = $NPCImage
@onready var text_box_toggle: CheckButton = $TextBoxToggle
@onready var text_box: Control = $TextBox
@onready var npc_name: Label = $TextBox/TextContainer/Margin/VBox/NPCName
@onready var npc_line: RichTextLabel \
= $TextBox/TextContainer/Margin/VBox/Scroll/ContentContainer/NPCLine
@onready var scroll: ScrollContainer = $TextBox/TextContainer/Margin/VBox/Scroll
@onready var button_container: VBoxContainer \
= $TextBox/TextContainer/Margin/VBox/Scroll/ContentContainer/ButtonContainer
@onready var close_dialogue_button: Button \
= $TextBox/TextContainer/Margin/VBox/Scroll/ContentContainer/ButtonContainer/CloseDialogueButton
@onready var text_stream_timer: Timer = $Timer

var player : Player
var player_name : String
var npc : NonPlayerCharacter
var initial_dialogue : Dialogue
var npc_relations : RelationshipComponent

@export var all_normal_dialogue : Array[Dialogue]

#TODO - (maybe?) after prio dialogue ends, continue with normal dialogue
#TODO - way to add prio dialogue to npc through events
#TODO - prio dialogue like arresting, doesnt get deleted or gets added to [0] if not solved
#TODO - make follow instant like dialogue attack
#TODO - prioritize using unlocked lines with id

# to unlock dialogue:  gui_node.dialogue_box.unlock_dialogue("test_event_unlock2", true)

func _ready() -> void:
	player = get_parent().get_parent()
	player_name = player.stats_component.character_name

func init(inc_npc : NonPlayerCharacter, inc_dialogue : Dialogue):
	for i in button_container.get_children():
		if !i.name == "CloseDialogueButton":
			i.queue_free()
	npc = inc_npc
	npc_relations = npc.relationship_component
	initial_dialogue = inc_dialogue
	npc_name.text = npc.stats_component.character_name
	#npc_relation.text = str(npc.relationship_component.faction_relations[0].get_relation(player_name))
	#npc_faction.text = npc.stats_component.faction_name
	var chosen_line = choose_dialogue(initial_dialogue)
	npc_line.text = chosen_line.text
	add_player_lines(chosen_line.id, initial_dialogue)
	#npc_image.texture = npc.character_image
	visible = true
	player.can_move = false
	player.can_attack = false
	player.is_in_dialogue = true
	text_stream_timer.start()

func next_init(dialogue : Dialogue, is_branch_end : bool):
	#npc_relation.text = str(npc_relations.faction_relations[0].get_relation(player_name))
	for i in button_container.get_children():
		if !i.name == "CloseDialogueButton":
			i.queue_free()
	if is_branch_end: # inits with initial_dialogue where npc line is the last dialogue from previous branch
		npc_line.text = dialogue.npc_lines[0].text
		add_player_lines("", initial_dialogue)
	else:
		var chosen_line = choose_dialogue(dialogue)
		npc_line.text = chosen_line.text
		add_player_lines(chosen_line.id, dialogue)
	text_stream_timer.start()

func choose_dialogue(dialogue : Dialogue):
	if dialogue.npc_lines.size() > 1:
		var number = 0
		var rng = RandomNumberGenerator.new()
		for i in dialogue.npc_lines.size(): # loops and tries to find a suitable npc_line
			number = rng.randf_range(0, dialogue.npc_lines.size())
			if dialogue.npc_lines[number].relation_requirement != 0:
				if dialogue.npc_lines[number].relation_requirement > 0:
					if npc_relations.faction_relations[0].get_relation(player_name)\
						>= dialogue.npc_lines[number].relation_requirement: # for relation above 0
						dialogue.npc_lines[number].is_locked = false
					else:
						dialogue.npc_lines[number].is_locked = true # locks dialogue if relation changes
				else:
					if npc_relations.faction_relations[0].get_relation(player_name)\
						<= dialogue.npc_lines[number].relation_requirement: # for relation below 0
						dialogue.npc_lines[number].is_locked = false
					else:
						dialogue.npc_lines[number].is_locked = true # locks dialogue if relation changes
			if !dialogue.npc_lines[number].already_said and !dialogue.npc_lines[number].is_locked:
				break
			else:
				number = 0
		if dialogue.npc_lines[number].id: # stops lines that should only be said once
			dialogue.npc_lines[number].already_said = true
		close_dialogue_button.visible = true # is there gonna be multi line npc dialogue with no exit?
		return dialogue.npc_lines[number]
	else:
		if !dialogue.npc_lines[0].can_exit:
			close_dialogue_button.visible = false
		return dialogue.npc_lines[0]

func add_player_lines(id : String, dialogue : Dialogue): # creates buttons for each player line
	npc_line.visible_characters = 0
	scroll.scroll_vertical = 0
	if id != "":
		for i in initial_dialogue.player_lines: # unlocks new dialogue based on previous dialogue
			if i.id == id:
				i.is_locked = false
	if dialogue.player_lines:
		for i in dialogue.player_lines:
			if i.id == id:
				i.is_locked = false
			if i.relation_requirement != 0: # unlock dialogue if relation high/low enough
				if i.relation_requirement > 0: # for relation above 0
					if npc_relations.faction_relations[0].get_relation(player_name) >= i.relation_requirement:
						i.is_locked = false
					else:
						i.is_locked = true # locks dialogue if relation changes
				else: # for relation below 0
					if npc_relations.faction_relations[0].get_relation(player_name) <= i.relation_requirement:
						i.is_locked = false
					else:
						i.is_locked = true # locks dialogue if relation changes
			if !i.is_locked:
				var button = Button.new()
				if i.text.contains("{player}"): # adds player name to dialogue
					button.text = i.text.format({"player" : player_name})
				else:
					button.text = i.text
				if i.already_said:
					button.add_theme_color_override("font_color", "DARK_SLATE_GRAY")
				button.pressed.connect(self._dialogue_button_pressed.bind(i))
				button_container.add_child(button)
				button_container.move_child(button, 0)
	else:
		next_init(dialogue, true)

func unlock_dialogue(id : String, is_player_dialogue : bool):
	for i in all_normal_dialogue:
		if is_player_dialogue:
			for z in i.player_lines:
				if z.id == id:
					z.is_locked = false
		else:
			for z in i.npc_lines:
				if z.id == id:
					z.is_locked = false

func _dialogue_button_pressed(line : DialogueLine): # when any player line button pressed
	line.already_said = true
	if line.relation_change != 0:
		npc_relations.change_char_relation(player_name, "PlayerFaction", line.relation_change, false)
	if line.next_dialogue:
		next_init(line.next_dialogue, false)
	elif line.opens_shop: # SHOP
		get_tree().root.get_child(3).shop_ui.init(npc)
		visible = false
	elif line.starts_combat: # sets player relation to HOSTILE_THRESHOLD unless already less than that
		if npc_relations.faction_relations[0].get_relation(player_name) > npc.HOSTILE_THRESHOLD:
			npc_relations.change_char_relation(player_name, "PlayerFaction", npc.HOSTILE_THRESHOLD, true)
		close_dialogue()
	else:
		print("dialogue has no next dialogue or anything else to end dialogue (dialogue box)")
		next_init(initial_dialogue, false)

func _on_close_dialogue_button_pressed() -> void: # when (close) button pressed
	close_dialogue()

func close_dialogue():
	visible = false
	player.can_move = true
	player.can_attack = true
	player.is_in_dialogue = false
	npc.is_in_dialogue = false
	
	# makes npc attack player if relation went below hostile threshold during the dialogue
	if npc_relations.faction_relations[0].get_relation(player_name) <= npc.HOSTILE_THRESHOLD:
		npc.dialogue_attack(npc_relations.faction_relations[0].get_relation(player_name))

func _on_text_box_toggle_pressed() -> void:
	if text_box_toggle.button_pressed:
		text_box.visible = false
	else:
		text_box.visible = true

func _on_timer_timeout() -> void:
	if npc_line.visible_ratio < 1:
		npc_line.visible_characters += 1
	else:
		text_stream_timer.stop()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			npc_line.visible_ratio = 1
