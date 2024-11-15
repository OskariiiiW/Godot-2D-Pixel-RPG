extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var trail_obj: GPUParticles2D = $Trail
@onready var impact_obj: GPUParticles2D = $Impact

@export var stats_component : StatsComponent

var projectile_name : String
var speed = 1.0
var projectile_duration = 1.0
var is_piercing = false
var knockback = 1.0
var damage = ItemElementType
var weapon_damage_multiplier = 1.0
var projectile_texture
var trail : ParticleProcessMaterial
var impact : ParticleProcessMaterial
var projectile_owner : Node2D

func _ready():
	if projectile_texture:
		sprite_2d.texture = projectile_texture
	if trail and impact:
		trail_obj.process_material = trail
		impact_obj.process_material = impact
		trail_obj.emitting = true
	if stats_component:
		var total_damage = damage.physical + damage.magical + damage.poison + damage.curse
		stats_component.health = total_damage
	else:
		print(self.name + " stats_component missing (ranged_projectile)")

func _physics_process(_delta):
	position += transform.x * speed
	await get_tree().create_timer(projectile_duration).timeout #BUG - counts down even if game paused
	handle_freeing(false)

func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent and area.get_parent() != projectile_owner:
		var has_same_owner = false
		if area.get_parent() is StaticBody2D:
			if area.get_parent().has_method("_physics_process"): # vewwy bad way to identify
				if area.get_parent().projectile_owner == projectile_owner:
					has_same_owner = true
		if !has_same_owner: # happens only when colliding with projectiles from other actors
			if area.stats_component:
				var hp_reduction = area.stats_component.health
				stats_component.health -= hp_reduction
				area.damage(damage)
				if stats_component.health <= 0 or !is_piercing:
					handle_freeing(true)
			else:
				print(area.get_parent().name + " is missing stats_component (ranged_projectile)")

func handle_freeing(collided : bool):
	if collided: # wtf was collided supposed to do???
		pass
	impact_obj.emitting = true
	trail_obj.emitting = false
	sprite_2d.visible = false
	hitbox_component.set_deferred("monitorable", false)
	hitbox_component.set_deferred("monitoring", false)
	await get_tree().create_timer(1).timeout
	queue_free()

func _on_hitbox_component_body_entered(body: Node2D) -> void: #collision with tilemap
	if body is TileMapLayer:
		handle_freeing(true)
