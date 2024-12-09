extends Resource

class_name ConsumableEffect

enum ElementType {NONE, PHYSICAL, POISON, MAGIC, CURSE}
enum StatType {HP, SP, MP, DMG, RES, SPEED}
enum EffectType {RESTORE, ENHANCE, REGEN, SKILLCOST}
enum AmountType {FLATVALUE, PERCENT}

@export var element_type : ElementType
@export var stat_type : StatType
@export var effect_type : EffectType
@export var amount_type : AmountType
@export var amount : float
@export var duration : float # if 0.0, effect will be instant (duh!) - since 0.6 != 1 sec, double check values
@export var can_stack : bool # whether same effect can appear as a buff multiple times
@export var icon : Texture2D # for buff/debuff UI
