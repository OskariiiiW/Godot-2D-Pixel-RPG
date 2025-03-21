extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var trail_obj: GPUParticles2D = $Trail
@onready var impact_obj: GPUParticles2D = $Impact
@onready var timer: Timer = $Timer

@export var stats_component : SimpleStatsComponent

var projectile_name : String
var speed = 1.0
var duration = 1.0
var is_piercing = false
var knockback = 1.0
var damage : Array[Element]
var weapon_damage_multiplier = 1.0
var projectile_texture
var trail : ParticleProcessMaterial
var impact : ParticleProcessMaterial
var p_owner : Node2D

func _ready():
	if projectile_texture:
		sprite_2d.texture = projectile_texture
	if trail and impact:
		trail_obj.process_material = trail
		impact_obj.process_material = impact
		trail_obj.emitting = true
	if !stats_component:
		print(self.name + " stats_component missing (ranged_projectile)")
	timer.wait_time = duration
	timer.start()

func init(_texture : Texture2D, _speed : float, _damage : Array[Element], total_dmg : float, _duration : float\
, _is_piercing : bool, _p_owner : Node):
	projectile_texture = _texture
	speed = _speed
	damage = _damage
	stats_component.health = total_dmg
	duration = _duration
	is_piercing = _is_piercing
	p_owner = _p_owner

func _physics_process(_delta):
	position += transform.x * speed

func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent and area.get_parent() != p_owner:
		var has_same_owner = false
		if area.get_parent() is StaticBody2D:
			if area.get_parent().has_method("_physics_process"): # vewwy bad way to identify
				if area.get_parent().p_owner == p_owner:
					has_same_owner = true
		if !has_same_owner: # happens only when colliding with projectiles from other actors
			var hp_reduction = 0.0 # amount to be reduced from projectile hp
			if area.stats_component:
				hp_reduction = area.stats_component.health
			elif area.simple_stats_component:
				hp_reduction = area.simple_stats_component.health
			else:
				print(area.get_parent().name + " is missing stats_component (ranged_projectile)")

			if hp_reduction != 0.0:
				stats_component.health -= hp_reduction
				area.damage(damage)
			if stats_component.health <= 0 or !is_piercing:
				handle_freeing(true)

func handle_freeing(collided : bool):
	if collided:
		impact_obj.emitting = true # if collided, creates explosion effect
	trail_obj.emitting = false
	sprite_2d.visible = false
	hitbox_component.set_deferred("monitorable", false)
	hitbox_component.set_deferred("monitoring", false)
	await get_tree().create_timer(1).timeout
	queue_free()

func _on_hitbox_component_body_entered(body: Node2D) -> void: #collision with tilemap
	if body is TileMapLayer:
		handle_freeing(true)

func _on_timer_timeout() -> void:
	handle_freeing(false)
