extends RigidBody3D

@export var move_speed = 1.0
@export var acceleration := 50.0
@export var max_health := 1000.0
@export var turn_speed := 0.01

@onready var _weapon_marker = %WeaponMarker

var weapon_name:NodePath
var weapon:Node3D

func _ready() -> void:
	weapon_name = "Handgun"
	weapon = Items.weapons[str(weapon_name)]['weapon_scene'].instantiate()
	add_child(weapon)
	weapon.set_weapon_type(weapon_name)
	weapon.enemy_pick_up()
	weapon.global_transform.origin = _weapon_marker.global_transform.origin
	weapon.rotation.y += deg_to_rad(180)
	weapon.set_deferred("freeze", true)
	#get_node("RBCollision/MeshInstance3D").surface_material_override(0.resource_local_to_scene = true)
	
func _physics_process(delta: float) -> void:
	var look_direction = get_angle(
		global_transform.origin, 
		get_parent().get_node("Player").global_transform.origin
	)
	global_rotation.y = lerp_angle(global_rotation.y, look_direction-1.55, turn_speed)
	# Move toward player
	var move_direction := global_basis.z
	move_direction.y = 0.0
	move_direction = -move_direction.normalized() * move_direction.length()
	var vel = linear_velocity.move_toward(move_direction * move_speed, acceleration * delta)
	linear_velocity.x = clamp(vel.x, -move_speed, move_speed)
	linear_velocity.y = 0.0
	linear_velocity.z = clamp(vel.z, -move_speed, move_speed)
	
func get_angle(a:Vector3, b:Vector3) -> float:
	return -atan2((b.z - a.z), (b.x - a.x))

func reset_material_color() -> void:
	$RBCollision/MeshInstance3D.material_override.emission = Color(0.2667, 0.4849, 1.0)
	$RBCollision/MeshInstance3D.material_override.emission_energy_multiplier = 0.01

func _on_reset_hit_color_timeout() -> void:
	reset_material_color()

func process_damage(dmg):
	$RBCollision/MeshInstance3D.material_override.emission = Color(100, 0 ,0)
	$ResetHitColor.start()
	max_health -= dmg
	if (max_health <= 0): #dedge
		# maybe make it explode here or something
		drop_weapon()
		reset_material_color()
		queue_free()

func _on_hit_box_area_entered(area: Area3D) -> void:
	if area.has_method("projectile_damage"):
		process_damage(area.projectile_damage())
		if (area.type=="Rocket" or area.type=="rocket"):
			var expl = Items.explosion.instantiate()
			get_parent().add_child(expl)
			expl.global_transform.origin = area.global_transform.origin
		area.queue_free()
	elif area.has_method("melee_damage"):
		process_damage(area.melee_damage())

func drop_weapon() -> void:
	weapon.drop()
	weapon.reparent(get_parent(), true)
	weapon.set_collision_layers(false, false)
	weapon.set_deferred("freeze", false)
	print(weapon)
	
	
