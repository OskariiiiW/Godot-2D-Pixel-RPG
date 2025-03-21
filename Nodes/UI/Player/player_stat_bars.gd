extends Control

@onready var health_bar: ProgressBar = $Margin/VBox/HealthBar
@onready var hp_current: Label = $Margin/VBox/HealthBar/HBox/Current
@onready var hp_max: Label = $Margin/VBox/HealthBar/HBox/Max

@onready var stamina_bar: ProgressBar = $Margin/VBox/StaminaBar
@onready var sp_current: Label = $Margin/VBox/StaminaBar/HBox/Current
@onready var sp_max: Label = $Margin/VBox/StaminaBar/HBox/Max

@onready var magicka_bar: ProgressBar = $Margin/VBox/MagickaBar
@onready var mp_current: Label = $Margin/VBox/MagickaBar/HBox/Current
@onready var mp_max: Label = $Margin/VBox/MagickaBar/HBox/Max

func init(hp : float, sp : float, mp : float):
	hp_max.text = str(hp)
	sp_max.text = str(sp)
	mp_max.text = str(mp)

func update_bar_values(hp : float, sp : float, mp : float):
	health_bar.value = snappedf(hp, 0.01)
	stamina_bar.value = snappedf(sp, 0.01)
	magicka_bar.value = snappedf(mp, 0.01)

func set_current_value(hp : float, sp : float, mp : float):
	hp_current.text = str(snappedf(hp, 0.01))
	sp_current.text = str(snappedf(sp, 0.01))
	mp_current.text = str(snappedf(mp, 0.01))

func change_max_value(value : float, type : int):
	if type == 0: # hp
		hp_max.text = str(value)
	elif type == 1: # sp
		sp_max.text = str(value)
	elif type == 2: # mp
		mp_max.text = str(value)
