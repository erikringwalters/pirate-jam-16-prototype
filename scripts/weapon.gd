extends RigidBody3D

@export var damage : float = 100.0
@export var is_projectile_weapon : bool = false

# DM Note: Couldn't figure out how to check which RigidBody3D model the weapon was using, so this was the next best thing I could think of.
@export_category("Weapon Type")
@export_enum("Handgun", "Rocket", "Shotgun", "Sword", "Dagger") var weapon_type : String

@export_category("Projectile Type")
@export_enum("Bullet", "Rocket") var projectile_type : String 
@export var scatter_shot : bool = false

@onready var is_pickedup = false
var _raycast:RayCast3D

# Conditional projectile weapon variables, will remain null if not projectile
var gun_barrel
var projectile_scene
var projectile

func _ready() -> void:
	if (projectile_type and projectile_type != ''):
		projectile_scene = Items.projectiles[projectile_type]
	else: # Default if no projectile type is selected
		projectile_scene = Items.projectiles['Bullet']
	if (is_projectile_weapon):
		#can_shoot = true
		_raycast = %RayCast
		gun_barrel = _raycast

func shoot() -> void:
	if (scatter_shot):
		# Spawn ten bullets
		for i in range(10):
			projectile = projectile_scene.instantiate()
			projectile.position = gun_barrel.global_position
			projectile.transform.basis = gun_barrel.global_transform.basis
			projectile.set_type(projectile_type)
			projectile.set_damage(Items.weapons[weapon_type]['base_damage'])
			projectile.set_collision_layers(is_pickedup)		
			# Randomly rotate each axis
			var axis = Vector3(1, 0, 0)
			var rotation_amount = float((randi() % 180) - 90)/1000
			projectile.transform.basis = projectile.transform.basis.rotated(axis, rotation_amount)
			axis = Vector3(0, 1, 0)
			rotation_amount = float((randi() % 180) - 90)/1000
			projectile.transform.basis = projectile.transform.basis.rotated(axis, rotation_amount)
			axis = Vector3(0, 0, 1)
			rotation_amount = float((randi() % 180) - 90)/1000
			projectile.transform.basis = projectile.transform.basis.rotated(axis, rotation_amount)		
			get_parent().add_child(projectile)
	else:
		projectile = projectile_scene.instantiate()
		projectile.position = gun_barrel.global_position
		projectile.transform.basis = gun_barrel.global_transform.basis
		projectile.set_type(projectile_type)
		projectile.set_damage(Items.weapons[weapon_type]['base_damage'])
		projectile.set_collision_layers(is_pickedup)
		get_parent().add_child(projectile)

func pick_up() -> void:
	is_pickedup = true
	set_collision_layers(false, true)
	# DM Note: On pickup, create and start an instanced timer for the newly attached weapon
	if(weapon_type):
		var timer = Timer.new()
		timer.wait_time = Items.weapons[weapon_type]['base_cooldown']
		add_child(timer)
		timer.start()
		timer.connect("timeout", Callable(self,"auto_shoot"))

# DM Note: Timer triggered auto_shoot function with console logs for each weapon type
func auto_shoot() -> void:
	if is_pickedup:
		shoot()

func melee_damage():
	return Items.weapons[weapon_type]['base_damage']

func drop() -> void:
	is_pickedup = false

func get_damage() -> float:
	return damage
	
func set_damage(num:int) -> void:
	damage = num

func set_collision_layers(is_held_by_enemy:bool, is_held_by_player:bool) -> void:
	set_collision_layer_value(CollisionLayers.COMMON, !is_held_by_enemy)
	set_collision_layer_value(CollisionLayers.PLAYER_DAMAGE, is_held_by_enemy)
	set_collision_layer_value(CollisionLayers.ENEMY_DAMAGE, is_held_by_player)
	set_collision_layer_value(CollisionLayers.PICKUP,
		!is_held_by_enemy && !is_held_by_player
	)
	

# get_collision_layer_value(CollisionLayers.ENEMY_DAMAGE) -> bullet.set
