extends Sprite2D

var is_ranged : bool
var projectile : RangedProjectile
var swing_speed : float
var damage : ItemElementType
var is_attacking : bool = false

@export var base_projectile_node : PackedScene
@export var equipped_item : ItemData :
	set(next_equipped):
		if next_equipped: # stops crash
			equipped_item = next_equipped
			self.texture = equipped_item.texture
			is_ranged = equipped_item.weapon.is_ranged
			projectile = equipped_item.weapon.projectile # might crash if null
			damage = equipped_item.weapon.damage
		else:
			equipped_item = null
			self.texture = null
			projectile = null
			damage = null

func ranged_attack(spawn_point : Transform2D, owner_node : Node2D):
	if equipped_item:
		var inst = base_projectile_node.instantiate()
		inst.projectile_texture = projectile.texture
		if projectile.trail:
			inst.trail = projectile.trail
			inst.impact = projectile.impact
		else:
			print("missing trail or impact (equippedItem)")
		inst.speed = projectile.speed
		inst.damage = projectile.damage
		inst.projectile_duration = projectile.projectile_duration
		inst.is_piercing = projectile.is_piercing
		inst.projectile_owner = owner_node
		owner.get_parent().get_parent().add_child(inst)
		inst.transform = spawn_point

func _on_collision_area_area_entered(area):
	if is_attacking:
		if not equipped_item.weapon.is_ranged:
			if area.has_method("damage"):
				area.damage(damage)
