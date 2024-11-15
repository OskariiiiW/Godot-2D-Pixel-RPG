extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D


@export var scene_to_load : String
@export var obj_texture : Texture2D

func _ready() -> void:
	if !scene_to_load:
		print("Scene missing from scene changer")
	
	if obj_texture:
		sprite_2d.texture = obj_texture

func interact():
	if scene_to_load:
		print("Interact")
		SceneTransition.change_scene(scene_to_load)
