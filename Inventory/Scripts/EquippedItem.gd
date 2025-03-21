extends Sprite2D

@onready var marker_container: Node2D = $MarkerContainer
@onready var shape_cast: ShapeCast2D = $ShapeCast2D

var is_ranged : bool
var projectile : RangedProjectile
var swing_speed : float

var total_dmg : float # for projectile hp in simple stats component
var damage : Array[Element] # for equipped weapon
var damage_buff : Array[Element]

var is_attacking : bool
var has_weapon : bool
var markers : Array[Marker2D]

@export var slotted_skills : Array[ActionSkill]
@export var base_projectile_node : PackedScene
@export var equipped_item : ItemData :
	set(next_equipped):
		if next_equipped: # stops crash
			equipped_item = next_equipped
			self.texture = equipped_item.icon
			is_ranged = equipped_item.weapon.is_ranged
			projectile = equipped_item.weapon.projectile # might crash if null
			#for i in equipped_item.weapon.damage.size(): # melee dmg only?
			#	var new_element = Element.new()
			#	new_element.element = equipped_item.weapon.damage[i].element
			#	new_element.value = equipped_item.weapon.damage[i].value
			#	damage.append(new_element)
			has_weapon = true
			update_dmg()
		else:
			has_weapon = false
			#equipped_item = null # dunno if needed
			self.texture = null
			#projectile = null
			damage.clear()

func _ready() -> void:
	for i in marker_container.get_children():
		markers.append(i)

func attack(owner_node : Node2D):
	if is_ranged:
		for i in range(equipped_item.weapon.projectile_count):
			projectile_attack(markers[i - 1].global_transform, projectile, damage.duplicate(), owner_node)
	else:
		print("currently npc have no melee, and player melee handled in player (equippedItem)")

func activate_skill(skill : ActionSkill, owner_node : Node2D):
	if skill.skill_type == 0: # 0 = projectile, 1 = beam, 2 = buff
		if skill.target_type == 0: # 0 = none, 1 = target, 2 = area
			var new_dmg : Array[Element]
			if damage_buff:
				for i in skill.damage:
					for x in damage_buff:
						if i.element == x.element:
							var new_element = Element.new()
							new_element.element = i.element
							i.value += x.value
							new_element.value = i.value + x.value
							new_dmg.append(new_element)
							break
			else:
				new_dmg = skill.damage.duplicate()
			for i in range(skill.target_count):
				projectile_attack(markers[i - 1].global_transform, skill.projectile, new_dmg, owner_node)
		get_parent().get_parent().stats_component.handle_stat_change(-skill.cost, true, skill.cost_type, true)
	elif skill.skill_type == 1: # beam
		if skill.beam_radius == shape_cast.shape.radius and skill.beam_length == shape_cast.target_position.x:
			if shape_cast.get_collision_count() > 0:
				var target_count
				if skill.target_count > shape_cast.get_collision_count():
					target_count = shape_cast.get_collision_count()
				else:
					target_count = skill.target_count
				var new_dmg : Array[Element]
				if damage_buff:
					for i in skill.damage:
						for x in damage_buff:
							if i.element == x.element:
								var new_element = Element.new()
								new_element.element = i.element
								i.value += x.value
								new_element.value = i.value + x.value
								new_dmg.append(new_element)
								break
				else:
					new_dmg = skill.damage.duplicate()
				for i in target_count:
					if shape_cast.get_collider(i) is HitboxComponent:
						shape_cast.get_collider(i).damage(new_dmg)
					else:
						if shape_cast.get_collider(i):
							print(shape_cast.get_collider(i).get_parent().name + " equippedItem")
			get_parent().get_parent().stats_component.handle_stat_change(-skill.cost, true, skill.cost_type,true)
		else:
			shape_cast.shape.radius = skill.beam_radius
			shape_cast.target_position.x = skill.beam_length
	elif skill.skill_type == 2: # buff
		if skill.target_type == 1: # target
			if skill.target_count == 1: # self buff
				for i in skill.effects:
					get_parent().get_parent().buff_list.add_buff(i)
			#else: # allies in an array and cycle through them?? shapecast2d??
			#	pass
		elif skill.target_type == 2: # area
			if skill.beam_radius == shape_cast.shape.radius \
			and skill.beam_length == shape_cast.target_position.x:
				var target_count
				if skill.target_count > shape_cast.get_collision_count():
					target_count = shape_cast.get_collision_count()
				else:
					target_count = skill.target_count
				for i in target_count:
					if shape_cast.get_collider(i) is HitboxComponent:
						for x in skill.effects:
							shape_cast.get_collider(i).add_buff(x)
							# missing a way to remove buff when time runs out (missing timer completely)
			else:
				shape_cast.shape.radius = skill.beam_radius
				shape_cast.target_position.x = skill.beam_length
		# TODO - multiple target buff handling

func projectile_attack(spawn_point : Transform2D, _projectile : RangedProjectile\
, dmg : Array[Element], owner_node : Node2D):
	#if equipped_item: # might be a redundant check
	var inst = base_projectile_node.instantiate()
	inst.init(_projectile.texture, _projectile.speed, dmg, total_dmg, _projectile.duration\
	, _projectile.is_piercing, owner_node)
	if _projectile.trail:
		inst.trail = _projectile.trail
		inst.impact = _projectile.impact
	else:
		print("missing trail or impact (equippedItem)")
	owner.get_parent().get_parent().add_child(inst)
	inst.transform = spawn_point

func update_buff(total_dmg_buff : Array[Element]):
	damage_buff = total_dmg_buff
	update_dmg()

func update_dmg():
	if equipped_item:
		damage.clear()
		if is_ranged:
			for i in projectile.damage.size():
				var new_element = Element.new()
				new_element.element = projectile.damage[i].element
				new_element.value = projectile.damage[i].value
				total_dmg += projectile.damage[i].value
				damage.append(new_element)
		else:
			for i in equipped_item.weapon.damage.size():
				var new_element = Element.new()
				new_element.element = equipped_item.weapon.damage[i].element
				new_element.value = equipped_item.weapon.damage[i].value
				damage.append(new_element)
		if damage_buff:
			for i in damage: # only applies dmg buff if already does same element dmg
				for x in damage_buff:
					if i.element == x.element:
						i.value += x.value
						total_dmg += x.value

func _on_collision_area_area_entered(area):
	if is_attacking:
		if not is_ranged:
			if area.has_method("damage"):
				area.damage(damage)
