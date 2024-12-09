extends CharacterBody2D

class_name Player

@onready var anim_object = $AnimatedSprite2D
@onready var weapon_container = $WeaponContainer
@onready var projectile_spawn_point = $WeaponContainer/ProjectileSpawnMark
@onready var equipped_item = $WeaponContainer/EquippedItem
@onready var weapon_anim_player = $WeaponContainer/AnimationPlayer
@onready var ray_cast = $RayCast2D
@onready var equipped_item_projectile = $WeaponContainer/EquippedItem.base_projectile_node
@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var GUI: CanvasLayer = $GUI

@export var stats_component : StatsComponent # dunno why tf not onready - bc called before its ready
@export var relationship_component : RelationshipComponent # dunno why tf not onready - bc called before its ready

var inventory_data
var player_stats_node # is this needed here?
var action_bar # is this needed here?
var player_stat_bars # is this needed here?
var buff_list # is this needed here?

const SPEED : float = 250.0
var speed_buff : float
var speed_mult : float = 1
var dodge_velocity : float = 1.8
var player_state
var last_player_direction : String = "down" #default direction
var can_attack : bool = true
var can_move : bool = true
var is_dodging : bool = false
var is_in_dialogue : bool = false
var is_dead : bool

var base_dodge_cost : float = 30.0

#TODO - convert current dodge movement reduction into a debuff
#TODO - add cooldown to dodge?? (skill based??)
#TODO - add cooldown to attacks (skill based??)

func _ready():
	inventory_data = GUI.player_inventory
	player_stats_node = GUI.player_stats
	#stats_component.resistances = GUI.player_stats.resistances
	action_bar = GUI.action_bar
	player_stat_bars = GUI.player_stat_bars
	buff_list = GUI.buff_list
	GUI.player = self
	if player_stat_bars: # inits hp bar (if player doesnt have full hp)
		stats_component.stat_bars_node = player_stat_bars
		stats_component.set_stat_bar_max_values()
	else:
		print("player missing player_stat_bars (player)")

func change_weapon(weapon : ItemData):
	if weapon.weapon: # bad check whether has itemdata
		equipped_item.equipped_item = weapon
	else:
		equipped_item.equipped_item = null

func collect_item(item : SlotData):
	if inventory_data:
		var remaining_stack = inventory_data.add_item(item)
		return remaining_stack # how many items in a stack are left after trying to add to player inv

func interact():
	if ray_cast.is_colliding():
		var obj = ray_cast.get_collider()
		print(obj.name + " (player_character)")
		if obj.has_method("interact"):
			print("try interact (player)")
			obj.interact()

func _input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event.is_pressed() and can_attack \
		and not event.is_echo():
		if weapon_container.visible:
			if !equipped_item.is_attacking:
				equipped_item.is_attacking = true
				if equipped_item.is_ranged == true: # ranged attack
					equipped_item.ranged_attack(projectile_spawn_point.global_transform, self)
					await get_tree().create_timer(0.5).timeout # make cooldown skill based?
				else: # melee attack
					weapon_anim_player.play("swing_weapon")
					await get_tree().create_timer(0.6).timeout # make cooldown and anim speed skill based?
				equipped_item.is_attacking = false
		else:
			weapon_container.visible = true

	if Input.is_action_just_pressed("interact"):
		interact()

	if Input.is_action_just_pressed("dodge"): #TODO- make timers skillbased?
		if velocity and !is_dodging and stats_component.stamina >= base_dodge_cost:
			is_dodging = true
			can_move = false
			velocity = velocity * dodge_velocity
			dodge()
			await get_tree().create_timer(0.2).timeout # duration of dodge "animation"
			can_move = true
			speed_mult -= 0.6  # = 0.4
			await get_tree().create_timer(0.5).timeout # duration of speed debuff
			speed_mult += 0.6
			is_dodging = false
		else:
			GUI.pop_up.add_message("Not enough stamina to dodge", 0)
			# 0 = misc, 1 = battle, 2 = dialogue, 3 = system, 4 = all

	if Input.is_action_just_pressed("toggle_weapon"):
		weapon_container.visible = !weapon_container.visible

	if Input.is_action_just_pressed("popup_test"): #TODO - make popup centered after changing text
		GUI.pop_up.queue_popup("aaiaiaiai")
		GUI.pop_up.add_message("The player was kinda cringe just now", 0)
		stats_component.add_xp("Skilltest", 1000)
	if Input.is_action_just_pressed("music_test"):
		MusicPlayer.play()

	if Input.is_action_just_pressed("skill_slot0"):
		action_bar.activate_slot(0, self)
	if Input.is_action_just_pressed("skill_slot1"):
		action_bar.activate_slot(1, self)
	if Input.is_action_just_pressed("skill_slot2"):
		action_bar.activate_slot(2, self)
	if Input.is_action_just_pressed("skill_slot3"):
		action_bar.activate_slot(3, self)
	if Input.is_action_just_pressed("skill_slot4"):
		action_bar.activate_slot(4, self)

func _physics_process(_delta):
	if can_move:
		var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if direction.x == 0 and direction.y == 0:
			player_state = "idle"
		elif direction.x < 0 and direction.y <= 0:
			player_state = "moving"
			last_player_direction = "left"
			ray_cast.target_position.x = -40
			ray_cast.target_position.y = 0
		elif direction.x < 0 and direction.y > 0: # possible 8-dir movement
			player_state = "moving"
			last_player_direction = "left"
		elif direction.x > 0 and direction.y <= 0:
			player_state = "moving"
			last_player_direction = "right"
			ray_cast.target_position.x = 40
			ray_cast.target_position.y = 0
		elif direction.x > 0 and direction.y > 0: # possible 8-dir movement
			player_state = "moving"
			last_player_direction = "right"
		elif direction.x == 0 and direction.y < 0:
			player_state = "moving"
			last_player_direction = "up"
			ray_cast.target_position.x = 0
			ray_cast.target_position.y = -40
		elif direction.x == 0 and direction.y > 0:
			player_state = "moving"
			last_player_direction = "down"
			ray_cast.target_position.x = 0
			ray_cast.target_position.y = 40
		velocity = direction * (SPEED + speed_buff) * speed_mult
	elif is_in_dialogue:
		velocity = Vector2.ZERO
		player_state = "idle"

	weapon_container.look_at(get_global_mouse_position())

	move_and_slide()

	play_anim()

func dodge():
	stats_component.handle_stat_change(-base_dodge_cost, true, ConsumableEffect.StatType.SP)
	hitbox.monitorable = false
	await get_tree().create_timer(0.4).timeout # TODO - make duration skillbased?
	hitbox.monitorable = true

func play_anim():
	if player_state == "idle":
		if last_player_direction == "up":
			anim_object.play("idle_up")
		elif last_player_direction == "left":
			anim_object.play("idle_left")
		elif last_player_direction == "right":
			anim_object.play("idle_right")
		elif last_player_direction == "down":
			anim_object.play("idle_down")
	elif player_state == "moving":
		if last_player_direction == "up":
			anim_object.play("move_up")
		elif last_player_direction == "left":
			anim_object.play("move_left")
		elif last_player_direction == "right":
			anim_object.play("move_right")
		elif last_player_direction == "down":
			anim_object.play("move_down")

func toggle_death():
	is_dead = !is_dead
	if is_dead:
		weapon_container.visible = false
		can_attack = false
		can_move = false
	else:
		can_attack = true
		can_move = true

func _on_timer_timeout() -> void:
	stats_component.handle_regeneration()

func _on_gui_handle_buff(element_type: Variant, stat_type: Variant, effect_type: Variant, \
amount_type: Variant, amount: Variant, is_added: Variant) -> void:
	stats_component.handle_buff(element_type, stat_type, effect_type, amount_type, amount, is_added)


func _on_gui_handle_weapon(weapon: Variant) -> void:
	change_weapon(weapon)
