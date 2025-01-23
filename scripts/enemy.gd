extends RigidBody3D

@export var move_speed = 1.0
@export var acceleration := 50.0
@export var max_health := 1000.0

@onready var _weapon_marker = %WeaponMarker

var weapon_name:NodePath

func _ready() -> void:
	weapon_name = "Sword"
	var weapon = Items.weapons[str(weapon_name)]['weapon_scene'].instantiate()
	add_child(weapon)
	weapon.set_collision_layers(true, false)
	weapon.freeze = true
	weapon.name = weapon_name
	weapon.rotation.y += deg_to_rad(180)
	weapon.global_transform.origin = _weapon_marker.global_transform.origin
	
func _physics_process(delta: float) -> void:
	# Look at player # TODO: Slowly look toward player to give player a chance to avoid/kite
	var look_direction = get_angle(
		global_transform.origin, 
		get_parent().get_node("Player").global_transform.origin
	)
	global_rotation.y = lerp_angle(global_rotation.y, look_direction-1.55, 0.05)
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

func _on_reset_hit_color_timeout() -> void:
	$RBCollision/MeshInstance3D.material_override.emission = Color(0.2667, 0.4849, 1.0)
	$RBCollision/MeshInstance3D.material_override.emission_energy_multiplier = 0.09

func process_damage(dmg):
	$RBCollision/MeshInstance3D.material_override.emission = Color(100, 0 ,0)
	$ResetHitColor.start()
	max_health -= dmg
	if (max_health <= 0): #dedge
		# maybe make it explode here or something
		drop_weapon()
		queue_free()

func _on_hit_box_area_entered(area: Area3D) -> void:
	if area.has_method("projectile_damage"):
		process_damage(area.projectile_damage())
	elif area.has_method("melee_damage"):
		process_damage(area.melee_damage())

func drop_weapon() -> void:
	var weapon = get_node(weapon_name)
	weapon.reparent(get_parent(), true)
	weapon.set_collision_layers(false, false)
	weapon.freeze = false
	print(weapon)
	
	
