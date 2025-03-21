extends CanvasLayer

signal handle_buff(element_type, stat_type, effect_type, amount_type, amount, is_added)
signal handle_weapon(weapon)

@onready var action_bar: Control = $ActionBar
@onready var player_inventory: PanelContainer = $PlayerInventory
#@onready var player_stats: VBoxContainer = $PlayerInventory/MarginContainer/PlayerStats
@onready var external_inventory: PanelContainer = $ExternalInventory
@onready var dialogue_box: Control = $DialogueBox
@onready var shop_ui: Control = $ShopUI
@onready var player_stat_bars: Control = $PlayerStatBars
@onready var buff_list: Control = $BuffList
@onready var pop_up: Control = $GUIMessages
@onready var fps: Label = $FPS

@export var player_stats : VBoxContainer # why export but not onready?? test after element sh8tshow

var player
var parent
var current_inventory_node # how tf do I set this --- wtf even is this?

func _ready():
	parent = get_parent()

func _process(_delta):
	if parent:
		if Input.is_action_just_pressed("inventory"):
			player_inventory.visible = !player_inventory.visible

			if player_inventory.visible:
				parent.can_attack = false
			else:
				parent.can_attack = true

		fps.text = str(Engine.get_frames_per_second())
		if Engine.get_frames_per_second() < 30.0:
			fps.set("theme_override_colors/font_color","Red")
		else:
			fps.set("theme_override_colors/font_color","White")
	

func init_external_inventory(slots, item_datas):
	external_inventory.init(slots, item_datas)
	external_inventory.visible = !external_inventory.visible

	if external_inventory.visible:
		parent.can_attack = false
	else:
		parent.can_attack = true

func hide_external_inventory():
	external_inventory.visible = false
	parent.can_attack = true

func _on_buff_list_handle_buff(element_type: Variant, stat_type: Variant, effect_type: Variant, \
amount_type: Variant, amount: Variant, is_added: Variant) -> void:
	handle_buff.emit(element_type, stat_type, effect_type\
	, amount_type, amount, is_added)

func _on_player_stats_handle_weapon(weapon: Variant) -> void:
	handle_weapon.emit(weapon)

func _on_player_stats_handle_stat(element_type: Variant, stat_type: Variant, effect_type: Variant, amount_type: Variant, amount: Variant, is_added: Variant) -> void:
	handle_buff.emit(element_type, stat_type, effect_type\
	, amount_type, amount, is_added)
