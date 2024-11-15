extends Resource

class_name ConsumableEffect

enum StatType {HP, SP, MP, DMG, SPEED}
enum EffectType {RESTORE, DAMAGE, ENHANCE, WEAKEN}

@export var stat_type : StatType
@export var effect_type : EffectType
@export var duration : float # if 0.0, effect will be instant (duh!)
@export var amount : float
