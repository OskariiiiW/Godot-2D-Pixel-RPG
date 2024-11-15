extends Resource

class_name DialogueLine

#used to unlock certain dialogue lines
@export var id : String
@export var text : String

# makes text grayed out if line already used (only Player)
@export var already_said : bool 

# locked behind certain skillcheck or topic (Both?)
@export var is_locked : bool

# whether 'close' button visible - being able to leave dialogue (only NPC)
@export var can_exit : bool = true

# if there is more dialogue behind the line (only Player)
@export var next_dialogue : Dialogue

# whether button opens shop when pressed (only Player)
@export var opens_shop : bool

# whether pressing the button will close dialogue and start combat (only Player)
@export var starts_combat : bool

# what relation change pressing the button causes (only Player)
@export var relation_change : int = 0

# if dialogue is locked, this amount of relation is required to unlock it (Both) (for NPC id required)
@export var relation_requirement : int = 0
