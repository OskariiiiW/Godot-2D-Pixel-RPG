extends Node2D

@onready var player: Player = $PlayerCharacter
@onready var gui : CanvasLayer = $PlayerCharacter/GUI
@onready var dialogue_box: Control = $PlayerCharacter/GUI/DialogueBox
@onready var shop_ui: Control = $PlayerCharacter/GUI/ShopUI
@onready var pause_menu : Control = $PlayerCharacter/GUI/PauseMenu

#TODO - when changing scene, save current scene

func _ready():
	pause_menu.visible = false
	print("Hello world!")
