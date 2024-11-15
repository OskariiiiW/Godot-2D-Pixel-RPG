extends Resource
class_name NPCTask

enum Type {ATTACK, COLLECT, DROPITEM, FOLLOW, SIT, CHEST_INTERACT, MOVE, TALK}

@export var type : Type
@export var attack_target : String
@export var collectable_item : ItemData # quantity not mentioned
@export var droppable_item : SlotData # quantity mentioned
@export var follow_target : String
@export var interactable : String
@export var move_target : Vector2
