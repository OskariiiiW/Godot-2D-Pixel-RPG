extends Resource

class_name ActionSkill

enum DmgType {PHYSICAL, MAGICAL, POISON, CURSE}
enum CostType {HP, SP, MP}

@export var name : String
@export var damage : float
@export var dmg_type : DmgType
@export var cost : float
@export var cost_type : CostType
@export var texture : Texture2D

# atm not used
