extends CharacterBody2D

class_name NonPlayerCharacter

@onready var nav_agent = $NavigationAgent2D
@onready var rotatable_container: Node2D = $Rotatable
@onready var weapon_container = $Rotatable/WeaponContainer
@onready var projectile_spawn_point = $Rotatable/WeaponContainer/ProjectileSpawnMark
@onready var equipped_item = $Rotatable/WeaponContainer/EquippedItem

const SPEED = 100.0 # 50
const HOSTILE_THRESHOLD = -70 # how low relation with player needs to be before npc will ne hostile

@export var character_image : Texture2D # currently only used in shop ui
@export var stats_component : StatsComponent
@export var relationship_component : RelationshipComponent
@export var dialogue_component : DialogueComponent

@export var inventory_data : InventoryData # what npc is carrying
@export var shop_inventory : InventoryData # what npc is selling
@export var gold : int # for shop only?

@export var tasks : Array[NPCTask]

enum State {IDLE, COMBAT, CHASE, FOLLOW, SEARCH, TASKS}

var speedmult : float
var target
var target_relation : int
var last_target_location
var has_target : bool
var on_cooldown : bool
var in_melee_range : bool
var is_alert : bool
var is_dead : bool
var is_in_dialogue : bool
var state : State

var interact_target

var rng = RandomNumberGenerator.new()

#TODO - replace sprite2d with animatedSprite
#TODO - if npc hit, give location where hit came from and change state to chase
#TODO - make every state check if there are tasks, if they do, do them instead
#TODO - add xp value to get when defeated
#TODO - only shoot projectiles if clear view to target (excl. destroyable props)

func _ready() -> void:
	if !is_alert:
		speedmult = 0.5
	else:
		speedmult = 1.0

func _physics_process(_delta):
	velocity = Vector2.ZERO
	if !is_dead and !is_in_dialogue:
		handle_state()

func handle_state():
	if state == State.IDLE:
		idle()
	elif state == State.COMBAT:
		combat()
	elif state == State.CHASE:
		chase()
	elif state == State.FOLLOW:
		follow()
	elif state == State.TASKS:
		#complete_tasks()
		pass

func complete_tasks():
	if tasks.size() == 0:
		set_state(State.IDLE)
	else:
		var task_completed = false
		if tasks[0].type == NPCTask.Type.ATTACK:
			set_state(State.COMBAT)
			# where target? who npc attacking?
		elif tasks[0].type == NPCTask.Type.FOLLOW:
			set_state(State.CHASE)
			# where target? who npc following?
		elif tasks[0].type == NPCTask.Type.SIT and interact_target:
			print("We sitting ovah here (npc)")
			task_completed = true
		elif tasks[0].type == NPCTask.Type.MOVE:
			move_to(tasks[0].move_target)
			if self.global_position.distance_to(tasks[0].move_target) < 40:
				print("MISSION COMPLETE RESPECT++ (npc)")
				task_completed = true
		if task_completed:
			print("task end (npc)")
			tasks.pop_front() # first element

func idle():
	if tasks.size() > 0:
		print("set state = tasks (npc)")
		state = State.TASKS

func combat():
	if target:
		if position.distance_to(target.global_position) > 125 and equipped_item.is_ranged: #ranged
			move_to(target.global_position)
		elif position.distance_to(target.global_position) > 10 and !equipped_item.is_ranged: #melee
			# does nothing atm
			rotatable_container.look_at(target.global_position)
		if not on_cooldown:
				if equipped_item.is_ranged:
					shoot_ranged_weapon()
				elif in_melee_range:
					print("swoosh (npc)")
	else:
		set_state(State.CHASE)

func chase():
	if position.distance_to(last_target_location) > 10:
		move_to(last_target_location)
	else:
		set_state(State.SEARCH)
		await get_tree().create_timer(5.0).timeout
		if !target:
			set_state(State.IDLE)

func search():
	pass
	#randomly move and rotate

func follow():
	if target:
		if position.distance_to(target.global_position) > 50: #maybe make distance into variable
			move_to(target.global_position)
			rotatable_container.look_at(target.global_position)
		elif target.name == "PlayerCharacter" and dialogue_component.prio_dialogue.size() > 0:
			if !is_in_dialogue: # stops spamming all prio dialogue at once
				is_in_dialogue = true
				get_tree().root.get_child(3).dialogue_box.init(self, dialogue_component.prio_dialogue[0])
				dialogue_component.prio_dialogue.remove_at(0)
	else:
		set_state(State.CHASE)

func interact():
	if !is_dead and !is_in_dialogue:
		if dialogue_component.dialogue and state != State.COMBAT: # possibly surrender dialogue??
			is_in_dialogue = true
			if dialogue_component.prio_dialogue.size() > 0:
				get_tree().root.get_child(3).dialogue_box.init(self, dialogue_component.prio_dialogue[0])
				dialogue_component.prio_dialogue.remove_at(0)
			else:
				get_tree().root.get_child(3).dialogue_box.init(self, dialogue_component.dialogue)
		else:
			print("no dialogue in dialogue_component (npc)")
	elif is_dead:
		print("dead (npc)")
		#TODO - open inventory with inventory_data - looting dead npc

func set_state(inc_state : State):
	speedmult = 1.0
	if inc_state == State.IDLE:
		print("set state = idle (npc)")
		set_alert(false)
		speedmult = 0.5
		state = State.IDLE
	elif inc_state == State.COMBAT:
		print("set state = combat (npc)")
		set_alert(true)
		state = State.COMBAT
	elif inc_state == State.CHASE:
		print("set state = chase (npc)")
		speedmult = 1
		state = State.CHASE
	elif inc_state == State.FOLLOW:
		print("set state = follow (npc)")
		state = State.FOLLOW
	elif inc_state == State.SEARCH:
		print("set state = search (npc)")
		state = State.SEARCH

func shoot_ranged_weapon():
	equipped_item.ranged_attack(projectile_spawn_point.global_transform, self)
	on_cooldown = true
	await get_tree().create_timer(1.0).timeout #TODO - make cooldown skill based? weapon based?
	on_cooldown = false

func _on_NPC_visual_body_entered(body):
	if !is_dead:
		if body.has_method("_physics_process"): # removes aggro on objects and dropped items
			print(str(body.name) + " in " + stats_component.character_name +  " vision (npc)")
			var new_target_relation = relationship_component.check_char_relation(\
				body.stats_component.character_name, body.stats_component.faction_name)
			var new_target_faction_relation = relationship_component.check_fact_relation(\
				body.stats_component.faction_name)
#BUG - if new_target_relation == null, check that faction exists in relationship_component
			if not has_target:
				if new_target_relation <= HOSTILE_THRESHOLD or new_target_faction_relation <= HOSTILE_THRESHOLD:
					target = body
					has_target = true
					target_relation = new_target_relation
					last_target_location = null
					print("last_target_location nulled (npc)")
					set_alert(true)
					set_state(State.COMBAT)
				elif new_target_relation > 70: #TODO - make a better way to handle follow
					target = body
					has_target = true
					set_state(State.FOLLOW)
			else: # checks if new target is more important than current
				if target_relation <= new_target_relation or target_relation <= new_target_faction_relation:
					print("already has target (npc)")
				else:
					print("aggro on " + str(body.name) + " (npc)")
					target = body
					target_relation = new_target_relation
			if body.name == "PlayerCharacter" and dialogue_component.prio_dialogue.size() > 0 \
			and state != State.COMBAT and state != State.CHASE:
				target = body
				has_target = true
				set_state(State.FOLLOW)

func _on_NPC_visual_body_exited(body):
	if !is_dead:
		#await get_tree().create_timer(5.0).timeout # makes chase a bit more flexible??
		if has_target and target == body: # stops target switch (bugging out) if someone leaves the area
			print("target lost (npc)")
			has_target = false
			last_target_location = body.global_position
			print("last_target_location set (npc)")
			target = null

func _on_melee_range_body_entered(_body):
	in_melee_range = true

func _on_melee_range_body_exited(_body):
	in_melee_range = false

func set_alert(alert : bool):
	if alert:
		is_alert = true
		weapon_container.visible = true
	else:
		is_alert = false
		weapon_container.visible = false

func dialogue_attack(player_relation : int): # only for attacking player because of dialogue
	target = get_tree().root.get_child(3).player
	has_target = true
	target_relation = player_relation
	last_target_location = null
	print("last_target_location nulled (npc)")
	set_alert(true)
	rotatable_container.look_at(target.global_position)
	state = State.IDLE # stops npc spamming dialogue even though combat should start
	await get_tree().create_timer(0.5).timeout # to create a little delay before npc starts blasting
	set_state(State.COMBAT)

func toggle_death(is_killed : bool):
	is_dead = is_killed
	if is_dead:
		set_alert(false)
		target = null
		has_target = false
		#last_target_location = null
		print("last_target_location nulled (npc)")
		print("i have become death, the destroyer of worlds (npc)")
	else:
		print("i have been resurrected (npc)")

func save_shop_inventory(value):
	shop_inventory = value

func add_item(item : SlotData): # gonna need another for normal inv maybe?
	shop_inventory.slot_datas.append(item)

func move_to(target_location):
	if nav_agent.target_position != target_location: # reduces movement jitter
		nav_agent.set_target_position(target_location)
	var next_nav_point = nav_agent.get_next_path_position()
	var new_velocity = (next_nav_point - global_transform.origin).normalized() * (SPEED * speedmult)
	if nav_agent.avoidance_enabled:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	else:
		velocity = (next_nav_point - global_transform.origin).normalized() * (SPEED * speedmult)
	rotatable_container.look_at(target_location)
	move_and_slide()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void: #idfk what dis does
	velocity = safe_velocity

func _on_timer_timeout() -> void: # creates new idle movement tasks
	if tasks.size() == 0 and state == State.IDLE:
		var rand_direction = Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0))
		var rand_dist = rng.randf_range(50.0, 300.0)
		var new_task = NPCTask.new()
		new_task.type = NPCTask.Type.MOVE
		new_task.move_target = self.global_position + (rand_direction * rand_dist)
		#tasks.append(new_task)
		print("idle tasks disabled (npc)")
		#print("new task added" + ", tasks size: " + str(tasks.size()))
		#print("set state = tasks")
		#state = State.TASKS

func _on_task_scanner_body_entered(body: Node2D) -> void:
	if !is_in_dialogue and state != State.COMBAT:
		if body.has_method("_physics_process"):
			for i in tasks.size():
				if tasks[i].type == NPCTask.Type.ATTACK:
					if body.stats_component.character_name == tasks[i].attack_target:
						print("attack task target found (npc)")
						tasks.clear()
						interact_target = body
						target = body
						set_state(State.COMBAT)
				elif tasks[i].type == NPCTask.Type.FOLLOW:
					if body.stats_component.character_name == tasks[i].follow_target:
						print("attack task target found (npc)")
						interact_target = body
						target = body
						set_state(State.CHASE)
						# when tf to "complete" follow task???

		#if tasks[1].type == NPCTask.Type.SIT and interact_target == null:
		#	tasks.clear()
		#	var new_task = NPCTask.new()
		#	new_task.type = NPCTask.Type.MOVE
		#	new_task.move_target = body.global_position
		#	tasks.append(new_task)
		#	var new_task2 = NPCTask.new() # maybe better way than deleting existing and making new tasks?
		#	new_task.type = NPCTask.Type.SIT
		#	tasks.append(new_task2)
		#	interact_target = body # test

func _on_task_scanner_body_exited(body: Node2D) -> void:
	if interact_target == body:
		if interact_target == null:
			last_target_location = body
