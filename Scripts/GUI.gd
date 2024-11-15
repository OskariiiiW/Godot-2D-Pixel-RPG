extends CanvasLayer

@onready var player_inventory = $PlayerInventory
@onready var external_inventory = $ExternalInventory
@onready var dialogue_box = $DialogueBox
@onready var shop_ui = $ShopUI
@onready var fps: Label = $FPS

var parent
var current_inventory_node # how tf do I set this --- wtf even is this?

func _ready():
	parent = get_parent()

func _process(_delta):
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
