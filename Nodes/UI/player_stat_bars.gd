extends Control

@onready var health_bar: ProgressBar = $Margin/VBox/HealthBar
@onready var stamina_bar: ProgressBar = $Margin/VBox/StaminaBar
@onready var magicka_bar: ProgressBar = $Margin/VBox/MagickaBar

func update_bar_values(health_value : float, stamina_value : float, magicka_value : float):
	health_bar.value = health_value
	stamina_bar.value = stamina_value
	magicka_bar.value = magicka_value
