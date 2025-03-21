extends Resource

class_name ActionSkill

enum CostType {HP, SP, MP}
enum SkillType {PROJECTILE, BEAM, BUFF}
enum TargetType {NONE, TARGET, AREA} # TARGET with count = 1 replaces SELF?
# projectile and target = homing projectile???
# projectile and area = aoe impact??

@export var name : String
@export var damage : Array[Element]
@export var cost : float
@export_multiline var description: String
@export var cost_type : CostType
@export var skill_type : SkillType
@export var target_type : TargetType
@export var projectile : RangedProjectile
@export var beam_length : float = 1
@export var beam_radius : float = 1
#export var beam_duration : float = 0 # how long beam will be active
@export var target_count : int = 1 # how many will be hit - beam only (buff??) - shapecast feature
@export var effects : Array[ConsumableEffect] # for buff
@export var icon : Texture2D
