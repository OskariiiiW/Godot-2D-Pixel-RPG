extends Resource

class_name Stats

@export var level : int = 1
@export var strength : int = 1 # more dmg with non dex melee weapons
@export var agility : int = 1 # more dodge (and speed?)
@export var dexterity : int = 1 # more dmg with dex weapons (better lockpicking?)
@export var endurance : int = 1 # more hp and stamina, more hp and stam recovery
@export var intelligence : int = 1 # more magicka - more magicka recovery
@export var perception : int = 1 # affects trap detection, more crit dmg
@export var charisma : int = 1 # better prices, (affects taming?) (persuade?)
@export var luck : int = 1 # bigger crit rate, hit value (affects taming?) (affects loot?) (affects minigames???)
@export var crit_rate : float
@export var crit_dmg : float
@export var hit_value : float # when calculating dmg, this affects how likely attack is to hit (if high dodge)
@export var dodge : float # when calculating dmg, this affects how likely the attack is to do no dmg
@export var kill_xp : int = 1 # how much xp killing this entity gives
